"use client";

import Link from "next/link";
import { useState } from "react";
import { CheckBadge } from "@/components/icons";
import { formatInr, thumbnailGradient } from "@/lib/courses";

type Props = {
  course: {
    slug: string;
    title: string;
    stream: string;
    teacher: string;
    hue: number;
    price: number;
    originalPrice: number;
    validity: string;
  };
};

const METHODS = [
  { name: "UPI", sub: "Pay by any UPI app", short: "UPI" },
  { name: "Google Pay", sub: "Linked UPI ID", short: "GP" },
  { name: "PhonePe", sub: "Linked account", short: "PP" },
  { name: "Debit / Credit Card", sub: "Visa, Mastercard, RuPay", short: "CARD" },
];

/**
 * Payment UI. Razorpay is not connected yet, so "Pay" completes a test
 * enrolment locally and the page says so — no money moves.
 */
export function CheckoutView({ course }: Props) {
  const [method, setMethod] = useState(0);
  const [coupon, setCoupon] = useState("");
  const [couponNote, setCouponNote] = useState<string | null>(null);
  const [orderId, setOrderId] = useState<string | null>(null);

  const discount = course.originalPrice - course.price;

  if (orderId) {
    return (
      <div className="mx-auto max-w-[520px] px-6 py-[72px] text-center">
        <span className="mx-auto flex size-16 items-center justify-center rounded-full bg-success-soft">
          <CheckBadge size={32} />
        </span>
        <h1 className="mt-5 text-[28px] font-bold tracking-[-0.02em] text-navy">Payment successful</h1>
        <p className="mt-2 text-[15px] text-muted">You&apos;re enrolled in {course.title}.</p>
        <div className="mt-7 rounded-xl border border-border bg-white text-left">
          {[
            ["Order ID", <span key="id" className="font-mono text-navy">{orderId}</span>],
            ["Amount paid", <span key="amt" className="font-semibold text-navy">{formatInr(course.price)}</span>],
            ["Method", <span key="m" className="font-semibold text-navy">{METHODS[method].name}</span>],
          ].map(([label, value], index) => (
            <div
              key={String(label)}
              className={`flex justify-between px-5 py-3.5 text-sm ${index < 2 ? "border-b border-line" : ""}`}
            >
              <span className="text-muted">{label}</span>
              {value}
            </div>
          ))}
        </div>
        <p className="mt-4 rounded-lg bg-amber-soft px-3 py-2 text-xs text-navy">
          Test mode — payments are not connected yet, so nothing was charged.
        </p>
        <div className="mt-6 flex flex-wrap justify-center gap-2.5">
          <Link
            href="/my-courses"
            className="flex h-[46px] items-center rounded-lg bg-primary px-[22px] text-[15px] font-semibold text-white hover:bg-primary-dark"
          >
            Start learning
          </Link>
          <Link
            href="/dashboard"
            className="flex h-[46px] items-center rounded-lg border border-primary-line px-[22px] text-[15px] font-semibold text-primary hover:bg-primary-soft"
          >
            Go to dashboard
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="mx-auto grid max-w-[1040px] items-start gap-7 px-4 pb-16 pt-10 sm:px-6 md:grid-cols-[minmax(0,1fr)_360px]">
      <div>
        <Link href={`/course/${course.slug}`} className="text-sm font-medium text-primary">
          ← Back to course
        </Link>
        <h1 className="mt-3 text-[28px] font-bold tracking-[-0.02em] text-navy">
          Complete your enrolment
        </h1>
        <section className="mt-6 rounded-xl border border-border bg-white p-6">
          <h2 className="text-base font-semibold text-navy">Payment method</h2>
          <div className="mt-4 flex flex-col gap-2.5">
            {METHODS.map((m, index) => {
              const on = method === index;
              return (
                <button
                  key={m.name}
                  type="button"
                  onClick={() => setMethod(index)}
                  className={`flex items-center gap-3.5 rounded-[10px] p-3.5 text-left ${
                    on ? "border-[1.5px] border-primary bg-surface-soft" : "border border-border bg-white"
                  }`}
                >
                  <span className="flex size-10 items-center justify-center rounded-lg bg-[#f2f3f7] text-xs font-bold text-navy">
                    {m.short}
                  </span>
                  <span className="flex-1">
                    <span className="block text-[15px] font-semibold text-navy">{m.name}</span>
                    <span className="text-[13px] text-muted">{m.sub}</span>
                  </span>
                  <span
                    className={`size-[18px] rounded-full ${on ? "border-[5px] border-primary" : "border-2 border-[#c7cad3]"}`}
                  />
                </button>
              );
            })}
          </div>
        </section>
        <form
          onSubmit={(e) => {
            e.preventDefault();
            if (coupon.trim()) setCouponNote(`“${coupon.trim()}” is not a valid coupon.`);
          }}
          className="mt-4 rounded-xl border border-border bg-white px-6 py-5"
        >
          <div className="flex gap-2.5">
            <input
              value={coupon}
              onChange={(e) => {
                setCoupon(e.target.value);
                setCouponNote(null);
              }}
              placeholder="Have a coupon code?"
              className="h-[42px] min-w-0 flex-1 rounded-lg border border-field px-3 text-sm outline-none focus:border-primary"
            />
            <button
              type="submit"
              className="h-[42px] rounded-lg border border-primary-line bg-white px-4 text-sm font-semibold text-primary hover:bg-primary-soft"
            >
              Apply
            </button>
          </div>
          {couponNote ? <p className="mt-2 text-[13px] text-danger">{couponNote}</p> : null}
        </form>
      </div>

      <aside className="overflow-hidden rounded-xl border border-border bg-white md:sticky md:top-6">
        <div className="p-5 text-white" style={{ background: thumbnailGradient(course.hue) }}>
          <p className="text-[11px] font-semibold tracking-[0.06em]">BIHAR BOARD · 90-DAY CRASH COURSE</p>
          <p className="mt-1.5 text-[17px] font-semibold">{course.title}</p>
          <p className="mt-1 text-[13px] text-[#dbe6ff]">
            {course.stream} · {course.teacher}
          </p>
        </div>
        <div className="flex flex-col gap-2.5 p-5 text-sm text-ink">
          <div className="flex justify-between">
            <span>Course price</span>
            <span>{formatInr(course.originalPrice)}</span>
          </div>
          {discount > 0 ? (
            <div className="flex justify-between">
              <span>Discount</span>
              <span className="text-success">− {formatInr(discount)}</span>
            </div>
          ) : null}
          <div className="flex justify-between border-t border-border pt-3 text-[17px] font-bold text-navy">
            <span>Total</span>
            <span>{formatInr(course.price)}</span>
          </div>
          <button
            type="button"
            onClick={() => setOrderId(`ABA-${new Date().getFullYear()}-${Math.floor(10000 + Math.random() * 90000)}`)}
            className="mt-2 h-12 rounded-lg bg-primary text-[15px] font-semibold text-white hover:bg-primary-dark"
          >
            Pay {formatInr(course.price)}
          </button>
          <p className="mt-1 text-xs leading-[1.5] text-muted">
            Access {course.validity.toLowerCase()}, including the full board revision series in January.
          </p>
        </div>
      </aside>
    </div>
  );
}
