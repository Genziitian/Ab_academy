import { errorResponse, fulfil, PaymentError, serviceDb, signatureMatches } from "@/lib/payments";

/**
 * Razorpay → us, for `payment.captured`. Unlocks the course even when the
 * student closed the tab before /api/verify-payment ran. Set the same secret
 * in Razorpay Dashboard → Webhooks and in RAZORPAY_WEBHOOK_SECRET.
 */
export async function POST(req: Request) {
  try {
    const secret = process.env.RAZORPAY_WEBHOOK_SECRET;
    if (!secret) throw new PaymentError("Webhook secret not set.", 503);

    const raw = await req.text();
    if (!signatureMatches(secret, raw, req.headers.get("x-razorpay-signature") ?? "")) {
      throw new PaymentError("Bad signature.", 400);
    }

    const event = JSON.parse(raw);
    if (event.event !== "payment.captured") return Response.json({ ignored: event.event });

    const payment = event.payload?.payment?.entity;
    const db = serviceDb();
    const { data: order } = await db
      .from("orders")
      .select("id")
      .eq("razorpay_order_id", payment?.order_id ?? "")
      .maybeSingle();
    if (!order) throw new PaymentError("Unknown order.", 404);

    await fulfil(db, order.id, payment.id, event);
    return Response.json({ ok: true });
  } catch (e) {
    return errorResponse(e);
  }
}
