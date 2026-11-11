import { errorResponse, fulfil, PaymentError, serviceDb, signatureMatches } from "@/lib/payments";

/**
 * Razorpay → us. Set the same secret in Razorpay Dashboard → Webhooks and in
 * RAZORPAY_WEBHOOK_SECRET, and subscribe to:
 *
 *   payment.captured  — unlocks the course even when the student closed the
 *                       tab before /api/verify-payment ran.
 *   refund.processed  — a full refund ends access to the course.
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
    const payment = event.payload?.payment?.entity;
    const db = serviceDb();

    if (event.event === "refund.processed") {
      const refund = event.payload?.refund?.entity;
      const paymentId = String(refund?.payment_id ?? payment?.id ?? "");
      const paid = Number(payment?.amount ?? 0);
      const refunded = Number(payment?.amount_refunded ?? refund?.amount ?? 0);
      // Partial refunds (a goodwill discount) keep access; a full one ends it.
      if (!paymentId || !paid || refunded < paid) return Response.json({ ignored: "partial refund" });
      const { error } = await db.rpc("revoke_refunded_order", { p_razorpay_payment_id: paymentId });
      if (error) {
        console.error("refund webhook failed:", error.message);
        throw new PaymentError("Could not record the refund.", 500);
      }
      return Response.json({ ok: true, refunded: paymentId });
    }

    if (event.event !== "payment.captured") return Response.json({ ignored: event.event });

    const { data: order } = await db
      .from("orders")
      .select("id, amount_inr")
      .eq("razorpay_order_id", payment?.order_id ?? "")
      .maybeSingle();
    if (!order) throw new PaymentError("Unknown order.", 404);

    // The event is signed, but still only unlock for the full price in rupees.
    if (payment.currency !== "INR" || Number(payment.amount) !== Math.round(Number(order.amount_inr) * 100)) {
      console.error("webhook amount mismatch for order", order.id, payment.amount, order.amount_inr);
      throw new PaymentError("Amount does not match the order.", 400);
    }

    await fulfil(db, order.id, payment.id, event);
    return Response.json({ ok: true });
  } catch (e) {
    return errorResponse(e);
  }
}
