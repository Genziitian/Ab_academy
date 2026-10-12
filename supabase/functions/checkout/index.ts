// Supabase Edge Function: sell a course through Razorpay.
//
// Deploy:  supabase functions deploy checkout --no-verify-jwt
// Secrets: supabase secrets set RAZORPAY_KEY_ID=... RAZORPAY_KEY_SECRET=... \
//                               RAZORPAY_WEBHOOK_SECRET=...
//
// Students cannot write `orders`, `payments` or `enrollments` (RLS), so every
// step that touches money runs here with the service role:
//
//   POST { action: "create", course_id }        → creates the order (and the
//        Razorpay order) and returns what the app's checkout sheet needs.
//   POST { action: "verify", order_id, razorpay_order_id,
//          razorpay_payment_id, razorpay_signature }
//        → checks Razorpay's signature, records the payment, enrols.
//   Razorpay webhook (payment.captured)          → the same fulfilment, for
//        payments whose app was closed before "verify" ran.
//
// JWT verification is off at the gateway because the webhook carries no user
// token; "create" and "verify" check the caller's token themselves.
//
// Without Razorpay keys the function refuses to sell, unless the secret
// ALLOW_TEST_CHECKOUT=true is set — then "create" returns test_mode and
// "complete_test" enrols for free. Never set that on production.

import { createClient, type SupabaseClient } from "jsr:@supabase/supabase-js@2";

const RAZORPAY_KEY_ID = Deno.env.get("RAZORPAY_KEY_ID") ?? "";
const RAZORPAY_KEY_SECRET = Deno.env.get("RAZORPAY_KEY_SECRET") ?? "";
const RAZORPAY_WEBHOOK_SECRET = Deno.env.get("RAZORPAY_WEBHOOK_SECRET") ?? "";
const ALLOW_TEST_CHECKOUT = Deno.env.get("ALLOW_TEST_CHECKOUT") === "true";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });

const admin = () =>
  createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!, {
    auth: { persistSession: false },
  });

async function hmacHex(secret: string, message: string) {
  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const sig = await crypto.subtle.sign("HMAC", key, new TextEncoder().encode(message));
  return [...new Uint8Array(sig)].map((b) => b.toString(16).padStart(2, "0")).join("");
}

/** Constant-time compare, so signature checks do not leak timing. */
function safeEqual(a: string, b: string) {
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return diff === 0;
}

async function callerId(req: Request, db: SupabaseClient) {
  const token = req.headers.get("Authorization")?.replace(/^Bearer\s+/i, "");
  if (!token) return null;
  const { data } = await db.auth.getUser(token);
  return data.user?.id ?? null;
}

/**
 * Marks an order paid, records the payment and enrols the student. Safe to
 * call twice for the same payment (app "verify" and the webhook can race).
 */
async function fulfil(
  db: SupabaseClient,
  orderId: string,
  paymentId: string,
  raw: unknown,
) {
  const { data: order, error } = await db
    .from("orders")
    .select("id, student_id, course_id, amount_inr, status")
    .eq("id", orderId)
    .maybeSingle();
  if (error || !order) throw new Error("Order not found.");

  if (order.status !== "paid") {
    const { error: updateError } = await db
      .from("orders")
      .update({ status: "paid", razorpay_payment_id: paymentId, paid_at: new Date().toISOString() })
      .eq("id", order.id)
      .neq("status", "paid");
    if (updateError) throw new Error(updateError.message);

    await db
      .from("payments")
      .upsert(
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

  const { data: batch } = await db
    .from("course_batches")
    .select("id")
    .eq("course_id", order.course_id)
    .order("created_at", { ascending: false })
    .limit(1)
    .maybeSingle();

  const { error: enrolError } = await db.from("enrollments").upsert(
    {
      student_id: order.student_id,
      course_id: order.course_id,
      batch_id: batch?.id ?? null,
      status: "active",
    },
    { onConflict: "student_id,course_id" },
  );
  if (enrolError) throw new Error(enrolError.message);

  return order;
}

async function create(req: Request, db: SupabaseClient, body: Record<string, unknown>) {
  const studentId = await callerId(req, db);
  if (!studentId) return json({ error: "Sign in to buy a course." }, 401);

  const courseId = String(body.course_id ?? "");
  const { data: course } = await db
    .from("courses")
    .select("id, title, price_inr, is_published")
    .eq("id", courseId)
    .maybeSingle();
  if (!course || !course.is_published) return json({ error: "This course is not on sale." }, 404);

  const { data: existing } = await db
    .from("enrollments")
    .select("id")
    .eq("student_id", studentId)
    .eq("course_id", course.id)
    .eq("status", "active")
    .maybeSingle();
  if (existing) return json({ error: "You are already enrolled in this course." }, 409);

  const testMode = !RAZORPAY_KEY_ID || !RAZORPAY_KEY_SECRET;
  if (testMode && !ALLOW_TEST_CHECKOUT) {
    return json({ error: "Payments are not set up yet. Please try again later." }, 503);
  }

  const { data: order, error } = await db
    .from("orders")
    .insert({ student_id: studentId, course_id: course.id, amount_inr: course.price_inr })
    .select("id")
    .single();
  if (error || !order) return json({ error: error?.message ?? "Could not create the order." }, 500);

  const { data: profile } = await db
    .from("profiles")
    .select("full_name, phone, email")
    .eq("id", studentId)
    .maybeSingle();

  const base = {
    order_id: order.id,
    amount_inr: course.price_inr,
    currency: "INR",
    course_title: course.title,
    prefill: { name: profile?.full_name ?? "", contact: profile?.phone ?? "", email: profile?.email ?? "" },
  };

  if (testMode) return json({ ...base, test_mode: true });

  // Razorpay amounts are in paise.
  const rzp = await fetch("https://api.razorpay.com/v1/orders", {
    method: "POST",
    headers: {
      Authorization: `Basic ${btoa(`${RAZORPAY_KEY_ID}:${RAZORPAY_KEY_SECRET}`)}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      amount: course.price_inr * 100,
      currency: "INR",
      receipt: order.id,
      notes: { order_id: order.id, course_id: course.id },
    }),
  });
  const rzpOrder = await rzp.json();
  if (!rzp.ok) {
    await db.from("orders").update({ status: "failed" }).eq("id", order.id);
    return json({ error: rzpOrder?.error?.description ?? "Razorpay rejected the order." }, 502);
  }

  await db
    .from("orders")
    .update({ razorpay_order_id: rzpOrder.id, status: "pending" })
    .eq("id", order.id);

  return json({ ...base, test_mode: false, razorpay_order_id: rzpOrder.id, key_id: RAZORPAY_KEY_ID });
}

async function verify(req: Request, db: SupabaseClient, body: Record<string, unknown>) {
  const studentId = await callerId(req, db);
  if (!studentId) return json({ error: "Sign in again to finish the payment." }, 401);

  const orderId = String(body.order_id ?? "");
  const rzpOrderId = String(body.razorpay_order_id ?? "");
  const paymentId = String(body.razorpay_payment_id ?? "");
  const signature = String(body.razorpay_signature ?? "");

  const { data: order } = await db
    .from("orders")
    .select("id, student_id, razorpay_order_id")
    .eq("id", orderId)
    .maybeSingle();
  if (!order || order.student_id !== studentId || order.razorpay_order_id !== rzpOrderId) {
    return json({ error: "This payment does not match your order." }, 400);
  }

  const expected = await hmacHex(RAZORPAY_KEY_SECRET, `${rzpOrderId}|${paymentId}`);
  if (!safeEqual(expected, signature)) {
    return json({ error: "Payment could not be verified." }, 400);
  }

  await fulfil(db, order.id, paymentId, body);
  return json({ ok: true, order_id: order.id, payment_id: paymentId });
}

async function completeTest(req: Request, db: SupabaseClient, body: Record<string, unknown>) {
  if (!ALLOW_TEST_CHECKOUT) return json({ error: "Test checkout is disabled." }, 403);
  const studentId = await callerId(req, db);
  if (!studentId) return json({ error: "Sign in again." }, 401);

  const { data: order } = await db
    .from("orders")
    .select("id, student_id")
    .eq("id", String(body.order_id ?? ""))
    .maybeSingle();
  if (!order || order.student_id !== studentId) return json({ error: "Order not found." }, 404);

  const paymentId = `test_${crypto.randomUUID()}`;
  await fulfil(db, order.id, paymentId, { test: true });
  return json({ ok: true, order_id: order.id, payment_id: paymentId, test_mode: true });
}

async function webhook(req: Request, db: SupabaseClient, raw: string) {
  const signature = req.headers.get("X-Razorpay-Signature") ?? "";
  if (!RAZORPAY_WEBHOOK_SECRET) return json({ error: "Webhook secret not set." }, 503);
  const expected = await hmacHex(RAZORPAY_WEBHOOK_SECRET, raw);
  if (!safeEqual(expected, signature)) return json({ error: "Bad signature." }, 400);

  const event = JSON.parse(raw);
  if (event.event !== "payment.captured") return json({ ignored: event.event });

  const payment = event.payload?.payment?.entity;
  const { data: order } = await db
    .from("orders")
    .select("id")
    .eq("razorpay_order_id", payment?.order_id ?? "")
    .maybeSingle();
  if (!order) return json({ error: "Unknown order." }, 404);

  await fulfil(db, order.id, payment.id, event);
  return json({ ok: true });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return json({ error: "POST only." }, 405);

  const db = admin();
  const raw = await req.text();

  try {
    if (req.headers.has("X-Razorpay-Signature")) return await webhook(req, db, raw);

    const body = JSON.parse(raw || "{}") as Record<string, unknown>;
    switch (body.action) {
      case "create":
        return await create(req, db, body);
      case "verify":
        return await verify(req, db, body);
      case "complete_test":
        return await completeTest(req, db, body);
      default:
        return json({ error: "Unknown action." }, 400);
    }
  } catch (e) {
    return json({ error: e instanceof Error ? e.message : String(e) }, 500);
  }
});
