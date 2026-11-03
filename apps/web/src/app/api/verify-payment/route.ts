import { callerId, errorResponse, fulfil, PaymentError, razorpay, serviceDb, signatureMatches } from "@/lib/payments";

/**
 * POST { razorpay_order_id, razorpay_payment_id, razorpay_signature }.
 * Checks HMAC-SHA256(order_id + "|" + payment_id, KEY_SECRET) against the
 * signature; only a match marks the order paid and unlocks the course.
 */
export async function POST(req: Request) {
  try {
    const studentId = await callerId(req);
    const body = (await req.json().catch(() => ({}))) as Record<string, string | undefined>;
    const orderId = body.razorpay_order_id;
    const paymentId = body.razorpay_payment_id;
    const signature = body.razorpay_signature;
    if (!orderId || !paymentId || !signature) {
      throw new PaymentError("Missing razorpay_order_id, razorpay_payment_id or razorpay_signature.", 400);
    }

    const { secret } = razorpay();
    if (!signatureMatches(secret, `${orderId}|${paymentId}`, signature)) {
      throw new PaymentError("Payment could not be verified.", 400);
    }

    const db = serviceDb();
    const { data: order } = await db
      .from("orders")
      .select("id, student_id")
      .eq("razorpay_order_id", orderId)
      .maybeSingle();
    if (!order || order.student_id !== studentId) throw new PaymentError("This payment does not match your order.", 400);

    await fulfil(db, order.id, paymentId, { razorpay_order_id: orderId, razorpay_payment_id: paymentId });
    return Response.json({ ok: true, receipt: order.id, payment_id: paymentId });
  } catch (e) {
    return errorResponse(e);
  }
}
