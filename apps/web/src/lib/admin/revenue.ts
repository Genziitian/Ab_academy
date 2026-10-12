// Revenue analytics, computed from the transaction log. Pure functions so the
// live and demo consoles share them.

import type { AdminTransaction } from "./types";

export type DayRevenue = { day: string; revenue: number; orders: number };
export type CourseRevenue = {
  courseId: string;
  title: string;
  code: string | null;
  revenue: number;
  orders: number;
};

export type RevenueSummary = {
  totalRevenue: number;
  todayRevenue: number;
  monthRevenue: number;
  paidOrders: number;
  failedOrders: number;
  refundedOrders: number;
  /** Orders that never completed: created or pending. */
  abandonedOrders: number;
  averageOrder: number;
  /** Paid orders as a share of every checkout started, 0–1. */
  conversion: number;
  payingStudents: number;
  /** The last `days` days, oldest first, with empty days included. */
  daily: DayRevenue[];
  byCourse: CourseRevenue[];
};

/** "YYYY-MM-DD" in India time, where the academy's day starts. */
export function istDay(iso: string) {
  return new Date(new Date(iso).getTime() + 330 * 60_000).toISOString().slice(0, 10);
}

export function summarize(rows: AdminTransaction[], days = 30, now = new Date()): RevenueSummary {
  const paid = rows.filter((r) => r.status === "paid");
  const today = istDay(now.toISOString());
  const month = today.slice(0, 7);
  const paidDay = (r: AdminTransaction) => istDay(r.paidAt ?? r.createdAt);

  const totalRevenue = paid.reduce((sum, r) => sum + r.amountInr, 0);

  const daily: DayRevenue[] = [];
  const byDay = new Map<string, DayRevenue>();
  for (let i = days - 1; i >= 0; i--) {
    const day = istDay(new Date(now.getTime() - i * 86_400_000).toISOString());
    const entry = { day, revenue: 0, orders: 0 };
    daily.push(entry);
    byDay.set(day, entry);
  }

  const courses = new Map<string, CourseRevenue>();
  for (const r of paid) {
    const entry = byDay.get(paidDay(r));
    if (entry) {
      entry.revenue += r.amountInr;
      entry.orders += 1;
    }
    const course = courses.get(r.courseId) ?? {
      courseId: r.courseId,
      title: r.courseTitle,
      code: r.courseCode,
      revenue: 0,
      orders: 0,
    };
    course.revenue += r.amountInr;
    course.orders += 1;
    courses.set(r.courseId, course);
  }

  return {
    totalRevenue,
    todayRevenue: paid.filter((r) => paidDay(r) === today).reduce((s, r) => s + r.amountInr, 0),
    monthRevenue: paid
      .filter((r) => paidDay(r).startsWith(month))
      .reduce((s, r) => s + r.amountInr, 0),
    paidOrders: paid.length,
    failedOrders: rows.filter((r) => r.status === "failed").length,
    refundedOrders: rows.filter((r) => r.status === "refunded").length,
    abandonedOrders: rows.filter((r) => r.status === "created" || r.status === "pending").length,
    averageOrder: paid.length ? Math.round(totalRevenue / paid.length) : 0,
    conversion: rows.length ? paid.length / rows.length : 0,
    payingStudents: new Set(paid.map((r) => r.studentId)).size,
    daily,
    byCourse: [...courses.values()].sort((a, b) => b.revenue - a.revenue),
  };
}
