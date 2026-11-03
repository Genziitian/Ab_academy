import { callerId, errorResponse, PaymentError, razorpay, serviceDb } from "@/lib/payments";

/**
 * POST { course_id } → creates our order and a Razorpay order for it.
 * The amount comes from the course's price in the database.
 */
export async function POST(req: Request) {
  try {
    const studentId = await callerId(req);
    const body = (await req.json().catch(() => ({}))) as { course_id?: string };
    if (!body.course_id) throw new PaymentError("Missing course_id.", 400);

    const db = serviceDb();
    const { data: course } = await db
      .from("courses")
      .select("id, title, price_inr, is_published")
      .eq("id", body.course_id)
      .maybeSingle();
    if (!course || !course.is_published) throw new PaymentError("This course is not on sale.", 404);

    const amount = Math.round(Number(course.price_inr) * 100); // paise
    if (!(amount >= 100)) throw new PaymentError("This course is free — no payment needed.", 400);

    const { data: existing } = await db
      .from("enrollments")
      .select("id")
      .eq("student_id", studentId)
      .eq("course_id", course.id)
      .eq("status", "active")
      .maybeSingle();
    if (existing) throw new PaymentError("You are already enrolled in this course.", 409);

    const { client, keyId } = razorpay();

    const { data: order, error } = await db
      .from("orders")
      .insert({ student_id: studentId, course_id: course.id, amount_inr: course.price_inr })
      .select("id")
      .single();
    if (error || !order) throw new PaymentError(error?.message ?? "Could not create the order.", 500);

    let rzpOrder: { id: string; amount: number | string; currency: string };
    try {
      rzpOrder = await client.orders.create({
        amount,
        currency: "INR",
        receipt: order.id,
        notes: { order_id: order.id, course_id: course.id },
      });
    } catch (e) {
      await db.from("orders").update({ status: "failed" }).eq("id", order.id);
      throw e;
    }

    await db.from("orders").update({ razorpay_order_id: rzpOrder.id, status: "pending" }).eq("id", order.id);

    const { data: profile } = await db.from("profiles").select("full_name, phone, email").eq("id", studentId).maybeSingle();

    return Response.json({
      order_id: rzpOrder.id,
      amount: Number(rzpOrder.amount),
      currency: rzpOrder.currency,
      key_id: keyId,
      receipt: order.id,
      course_title: course.title,
      prefill: { name: profile?.full_name ?? "", email: profile?.email ?? "", contact: profile?.phone ?? "" },
    });
  } catch (e) {
    return errorResponse(e);
  }
}
