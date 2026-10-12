import { type NextRequest } from "next/server";
import { requireSuperAdmin } from "@/lib/admin/auth";
import { listTransactions } from "@/lib/admin/data";

/** The transaction log as CSV, with the same search and status filters. */
export async function GET(request: NextRequest) {
  await requireSuperAdmin();

  const params = request.nextUrl.searchParams;
  const query = params.get("q")?.trim().toLowerCase() ?? "";
  const status = params.get("status") ?? "";

  const rows = (await listTransactions()).filter((t) => {
    if (status === "created" && t.status !== "created" && t.status !== "pending") return false;
    if (status && status !== "created" && t.status !== status) return false;
    if (!query) return true;
    return [
      t.studentName,
      t.studentEmail,
      t.studentCode,
      t.courseTitle,
      t.courseCode,
      t.razorpayOrderId,
      t.razorpayPaymentId,
    ].some((v) => v?.toLowerCase().includes(query));
  });

  const header = [
    "created_at",
    "paid_at",
    "status",
    "amount_inr",
    "coupon",
    "student",
    "student_email",
    "student_code",
    "course",
    "course_code",
    "razorpay_order_id",
    "razorpay_payment_id",
  ];
  const lines = rows.map((t) =>
    [
      t.createdAt,
      t.paidAt ?? "",
      t.status,
      t.amountInr,
      t.couponCode ?? "",
      t.studentName,
      t.studentEmail ?? "",
      t.studentCode ?? "",
      t.courseTitle,
      t.courseCode ?? "",
      t.razorpayOrderId ?? "",
      t.razorpayPaymentId ?? "",
    ]
      .map(csvCell)
      .join(","),
  );

  const day = new Date().toISOString().slice(0, 10);
  return new Response([header.join(","), ...lines].join("\r\n"), {
    headers: {
      "Content-Type": "text/csv; charset=utf-8",
      "Content-Disposition": `attachment; filename="transactions-${day}.csv"`,
      "Cache-Control": "private, no-store",
    },
  });
}

/**
 * Quote every cell, and defuse values a spreadsheet would run as a formula
 * (a student can choose their own name).
 */
function csvCell(value: string | number) {
  let text = String(value);
  if (/^[=+\-@\t\r]/.test(text)) text = `'${text}`;
  return `"${text.replace(/"/g, '""')}"`;
}
