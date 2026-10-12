import Link from "next/link";
import { Card, EmptyRow, PageHeader, Pill } from "@/components/admin/AdminChrome";
import { requireSuperAdmin } from "@/lib/admin/auth";
import { listTransactions } from "@/lib/admin/data";
import { formatRupees, formatWhen } from "@/lib/admin/format";
import { summarize } from "@/lib/admin/revenue";
import type { OrderStatus } from "@/lib/admin/types";

export const metadata = { title: "Transactions" };

const RANGES = [7, 30, 90] as const;
const STATUSES: { value: OrderStatus | ""; label: string }[] = [
  { value: "", label: "All statuses" },
  { value: "paid", label: "Paid" },
  { value: "failed", label: "Failed" },
  { value: "created", label: "Not completed" },
  { value: "refunded", label: "Refunded" },
];

const inputClass =
  "mt-1 rounded-xl border border-border bg-surface px-3 py-2 text-sm text-navy outline-none focus:border-primary";

export default async function TransactionsPage({
  searchParams,
}: {
  searchParams: Promise<{ q?: string; status?: string; days?: string }>;
}) {
  await requireSuperAdmin();
  const { q, status, days: daysParam } = await searchParams;
  const days = RANGES.find((d) => String(d) === daysParam) ?? 30;

  const all = await listTransactions();
  const summary = summarize(all, days);

  const query = q?.trim().toLowerCase() ?? "";
  const rows = all.filter((t) => {
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
  const shown = rows.slice(0, 200);

  const rangeRevenue = summary.daily.reduce((s, d) => s + d.revenue, 0);
  const peak = Math.max(1, ...summary.daily.map((d) => d.revenue));

  const stats = [
    { label: "Total revenue", value: formatRupees(summary.totalRevenue), hint: "all paid orders" },
    { label: "This month", value: formatRupees(summary.monthRevenue), hint: "India time" },
    { label: "Today", value: formatRupees(summary.todayRevenue), hint: "India time" },
    {
      label: "Paid orders",
      value: summary.paidOrders.toLocaleString("en-IN"),
      hint: `${summary.payingStudents} paying student${summary.payingStudents === 1 ? "" : "s"}`,
    },
    { label: "Average order", value: formatRupees(summary.averageOrder), hint: "per paid order" },
    {
      label: "Conversion",
      value: `${Math.round(summary.conversion * 100)}%`,
      hint: "checkouts that were paid",
    },
    { label: "Failed", value: summary.failedOrders, hint: "payment declined" },
    {
      label: "Not completed",
      value: summary.abandonedOrders,
      hint: `${summary.refundedOrders} refunded`,
    },
  ];

  const exportHref = `/admin/transactions/export?${new URLSearchParams({
    ...(q ? { q } : {}),
    ...(status ? { status } : {}),
  })}`;

  return (
    <>
      <PageHeader
        title="Transactions"
        description="Every checkout, its Razorpay payments and the revenue they add up to. Visible to the super admin only."
        action={
          <a
            href={exportHref}
            className="rounded-xl border border-border bg-surface px-4 py-2 text-sm font-semibold text-navy transition-colors hover:bg-surface-soft"
          >
            Export CSV
          </a>
        }
      />

      <div className="grid grid-cols-2 gap-4 lg:grid-cols-4">
        {stats.map((stat) => (
          <Card key={stat.label}>
            <p className="text-xs font-medium tracking-wide text-muted uppercase">{stat.label}</p>
            <p className="mt-2 text-2xl font-semibold tracking-tight text-navy">{stat.value}</p>
            <p className="mt-1 text-xs text-muted">{stat.hint}</p>
          </Card>
        ))}
      </div>

      <div className="mt-6 grid gap-4 lg:grid-cols-[1.6fr_1fr]">
        <Card>
          <div className="mb-4 flex flex-wrap items-center justify-between gap-3">
            <div>
              <h2 className="font-semibold text-navy">Revenue by day</h2>
              <p className="text-xs text-muted">
                {formatRupees(rangeRevenue)} in the last {days} days
              </p>
            </div>
            <div className="flex gap-1">
              {RANGES.map((d) => (
                <Link
                  key={d}
                  href={`/admin/transactions?${new URLSearchParams({
                    ...(q ? { q } : {}),
                    ...(status ? { status } : {}),
                    days: String(d),
                  })}`}
                  className={`rounded-lg px-2.5 py-1 text-xs font-semibold ${
                    d === days ? "bg-primary-soft text-primary" : "text-muted hover:text-navy"
                  }`}
                >
                  {d}d
                </Link>
              ))}
            </div>
          </div>
          <div className="flex h-44 items-end gap-[2px]" role="img" aria-label="Daily revenue">
            {summary.daily.map((d) => (
              <div
                key={d.day}
                title={`${d.day}: ${formatRupees(d.revenue)} · ${d.orders} order${d.orders === 1 ? "" : "s"}`}
                className="flex-1 rounded-t bg-primary/80 hover:bg-primary"
                style={{ height: `${d.revenue === 0 ? 1 : Math.max(4, (d.revenue / peak) * 100)}%` }}
              />
            ))}
          </div>
          <div className="mt-2 flex justify-between text-[11px] text-muted">
            <span>{summary.daily[0]?.day}</span>
            <span>{summary.daily.at(-1)?.day}</span>
          </div>
        </Card>

        <Card>
          <h2 className="mb-4 font-semibold text-navy">Revenue by course</h2>
          {summary.byCourse.length === 0 ? (
            <EmptyRow>No paid orders yet.</EmptyRow>
          ) : (
            <ul className="space-y-3">
              {summary.byCourse.map((c) => (
                <li key={c.courseId}>
                  <div className="flex items-baseline justify-between gap-3 text-sm">
                    <span className="truncate font-medium text-navy">{c.title}</span>
                    <span className="whitespace-nowrap text-navy">{formatRupees(c.revenue)}</span>
                  </div>
                  <div className="mt-1 h-1.5 rounded-full bg-surface-soft">
                    <div
                      className="h-1.5 rounded-full bg-primary"
                      style={{
                        width: `${(c.revenue / Math.max(1, summary.totalRevenue)) * 100}%`,
                      }}
                    />
                  </div>
                  <p className="mt-0.5 text-xs text-muted">
                    <span className="font-mono">{c.code}</span> · {c.orders} order
                    {c.orders === 1 ? "" : "s"}
                  </p>
                </li>
              ))}
            </ul>
          )}
        </Card>
      </div>

      <Card className="mt-6">
        <form className="mb-4 flex flex-wrap items-end gap-3">
          <input type="hidden" name="days" value={days} />
          <label className="block">
            <span className="text-xs font-medium text-navy">Search</span>
            <input
              name="q"
              defaultValue={q ?? ""}
              placeholder="Student, code, course or Razorpay id"
              className={`${inputClass} w-72`}
            />
          </label>
          <label className="block">
            <span className="text-xs font-medium text-navy">Status</span>
            <select name="status" defaultValue={status ?? ""} className={inputClass}>
              {STATUSES.map((s) => (
                <option key={s.value} value={s.value}>
                  {s.label}
                </option>
              ))}
            </select>
          </label>
          <button
            type="submit"
            className="rounded-xl bg-primary px-4 py-2 text-sm font-semibold text-white transition-colors hover:bg-primary-dark"
          >
            Filter
          </button>
          {q || status ? (
            <Link
              href={`/admin/transactions?days=${days}`}
              className="px-2 py-2 text-sm font-medium text-muted hover:text-navy"
            >
              Clear
            </Link>
          ) : null}
        </form>

        <h2 className="mb-3 font-semibold text-navy">
          Transaction log{" "}
          <span className="text-sm font-normal text-muted">
            {rows.length > shown.length
              ? `latest ${shown.length} of ${rows.length}`
              : `${rows.length} order${rows.length === 1 ? "" : "s"}`}
          </span>
        </h2>

        {shown.length === 0 ? (
          <EmptyRow>
            {all.length === 0
              ? "No checkouts yet. Orders appear here as soon as a student starts paying."
              : "Nothing matches these filters."}
          </EmptyRow>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm">
              <thead>
                <tr className="text-xs text-muted">
                  <th className="pb-2 font-medium">When</th>
                  <th className="pb-2 font-medium">Student</th>
                  <th className="pb-2 font-medium">Course</th>
                  <th className="pb-2 font-medium">Amount</th>
                  <th className="pb-2 font-medium">Status</th>
                  <th className="pb-2 font-medium">Razorpay</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-border">
                {shown.map((t) => (
                  <tr key={t.id} className="align-top">
                    <td className="py-3 pr-3 whitespace-nowrap text-navy">
                      {formatWhen(t.createdAt)}
                      {t.paidAt ? (
                        <p className="text-xs text-muted">paid {formatWhen(t.paidAt)}</p>
                      ) : null}
                    </td>
                    <td className="py-3 pr-3">
                      <p className="font-medium text-navy">{t.studentName}</p>
                      <p className="font-mono text-xs text-primary">{t.studentCode ?? "—"}</p>
                      {t.studentEmail ? (
                        <p className="text-xs text-muted">{t.studentEmail}</p>
                      ) : null}
                    </td>
                    <td className="py-3 pr-3">
                      <p className="text-navy">{t.courseTitle}</p>
                      <p className="font-mono text-xs text-muted">{t.courseCode}</p>
                    </td>
                    <td className="py-3 pr-3 whitespace-nowrap text-navy">
                      {formatRupees(t.amountInr)}
                      {t.couponCode ? (
                        <p className="text-xs text-muted">coupon {t.couponCode}</p>
                      ) : null}
                    </td>
                    <td className="py-3 pr-3">
                      <Pill
                        status={t.status}
                        label={t.status === "created" ? "not completed" : t.status}
                      />
                    </td>
                    <td className="py-3 text-xs text-muted">
                      <p className="font-mono">{t.razorpayOrderId ?? "—"}</p>
                      {t.payments.length > 0 ? (
                        <details className="mt-1">
                          <summary className="cursor-pointer text-primary">
                            {t.payments.length} payment event
                            {t.payments.length === 1 ? "" : "s"}
                          </summary>
                          <ul className="mt-1 space-y-1">
                            {t.payments.map((p) => (
                              <li key={p.id}>
                                <span className="font-mono">{p.razorpayPaymentId ?? "—"}</span> ·{" "}
                                {p.status} · {formatRupees(p.amountInr)} ·{" "}
                                {formatWhen(p.createdAt)}
                              </li>
                            ))}
                          </ul>
                        </details>
                      ) : null}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </Card>
    </>
  );
}
