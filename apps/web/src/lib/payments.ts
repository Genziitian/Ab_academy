// Razorpay checkout, server side. Used by the /api/create-order,
// /api/verify-payment and /api/razorpay-webhook routes.
//
// Students cannot write orders, payments or enrollments (RLS), so every step
// that touches money runs here with the service-role client. Prices always
// come from the database, never from the browser.

import "server-only";
import { createHmac, timingSafeEqual } from "node:crypto";
import type { SupabaseClient } from "@supabase/supabase-js";
import Razorpay from "razorpay";
import { createServerClient, createServiceClient } from "@/lib/supabase/server";

export class PaymentError extends Error {
  constructor(
    message: string,
    readonly status: number,
  ) {
    super(message);
  }
}

export function razorpay() {
  const key_id = process.env.RAZORPAY_KEY_ID;
  const key_secret = process.env.RAZORPAY_KEY_SECRET;
  if (!key_id || !key_secret) throw new PaymentError("Payments are not set up yet. Please try again later.", 503);
  return { client: new Razorpay({ key_id, key_secret }), keyId: key_id, secret: key_secret };
}

export function serviceDb(): SupabaseClient {
  const db = createServiceClient();
  if (!db) throw new PaymentError("Payments are not set up yet. Please try again later.", 503);
  return db;
}

/**
 * The signed-in student: the website's session cookie, or a Supabase access
 * token in `Authorization: Bearer …` (the mobile app).
 */
export async function callerId(req: Request): Promise<string> {
  const bearer = req.headers.get("authorization")?.replace(/^Bearer\s+/i, "");
  if (bearer) {
    const { data } = await serviceDb().auth.getUser(bearer);
    if (data.user) return data.user.id;
  } else {
    const supabase = await createServerClient();
    const { data } = (await supabase?.auth.getUser()) ?? { data: { user: null } };
    if (data.user) return data.user.id;
  }
  throw new PaymentError("Sign in to buy a course.", 401);
}

/** HMAC-SHA256 hex digest, compared in constant time. */
export function signatureMatches(secret: string, payload: string, signature: string) {
  const expected = Buffer.from(createHmac("sha256", secret).update(payload).digest("hex"));
  const given = Buffer.from(String(signature));
  return expected.length === given.length && timingSafeEqual(expected, given);
}

/**
 * Marks an order paid, records the payment and enrols the student. Safe to
 * run twice for the same payment (verify and the webhook can race).
 */
export async function fulfil(db: SupabaseClient, orderId: string, paymentId: string, raw: unknown) {
  const { data: order, error } = await db
    .from("orders")
    .select("id, student_id, course_id, amount_inr, status")
    .eq("id", orderId)
    .maybeSingle();
  if (error || !order) throw new PaymentError("Order not found.", 404);

  if (order.status !== "paid") {
    const { error: updateError } = await db
      .from("orders")
      .update({ status: "paid", razorpay_payment_id: paymentId, paid_at: new Date().toISOString() })
      .eq("id", order.id)
      .neq("status", "paid");
    if (updateError) throw new PaymentError(updateError.message, 500);

    await db.from("payments").upsert(
      {
        order_id: order.id,
        razorpay_payment_id: paymentId,
        amount_inr: order.amount_inr,
        status: "captured",
        raw_payload: raw ?? null,
      },
      { onConflict: "razorpay_payment_id" },
    );
  }

  if (!order.student_id) return order; // account deleted since; keep the record only

  const { data: batch } = await db
    .from("course_batches")
    .select("id")
    .eq("course_id", order.course_id)
    .order("created_at", { ascending: false })
    .limit(1)
    .maybeSingle();

  const { error: enrolError } = await db.from("enrollments").upsert(
    { student_id: order.student_id, course_id: order.course_id, batch_id: batch?.id ?? null, status: "active" },
    { onConflict: "student_id,course_id" },
  );
  if (enrolError) throw new PaymentError(enrolError.message, 500);
  return order;
}

/** JSON error response from anything thrown in a payment route. */
export function errorResponse(e: unknown) {
  if (e instanceof PaymentError) return Response.json({ error: e.message }, { status: e.status });
  // Razorpay SDK errors carry the HTTP status of Razorpay's reply.
  const sdk = e as { statusCode?: number; error?: { description?: string } };
  if (sdk?.statusCode === 401) {
    return Response.json({ error: "The payment gateway rejected our keys. Please contact support." }, { status: 401 });
  }
  if (sdk?.statusCode) {
    return Response.json({ error: sdk.error?.description ?? "The payment gateway returned an error." }, { status: 500 });
  }
  console.error("payment route failed:", e);
  return Response.json({ error: "Something went wrong. Nothing was charged — please try again." }, { status: 500 });
}
