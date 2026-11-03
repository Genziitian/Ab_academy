"use client";

import { createBrowserClient } from "@supabase/ssr";
import Image from "next/image";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { CheckBadge } from "@/components/icons";
import { LanguageToggle } from "@/components/LanguagePicker";
import { CONTACT } from "@/lib/landing";
import { formatInr, type CourseLanguage } from "@/lib/courses";

type Props = {
  enrolled: boolean;
  initialLanguage: CourseLanguage;
  student: { name: string; contact: string };
  course: {
    id: string | null;
    slug: string;
    title: string;
    teacher: string;
    art: string | null;
    price: number;
    originalPrice: number;
    validity: string;
  };
};

type Receipt = { orderId: string; amount: number; testMode: boolean; language: CourseLanguage };

type RazorpayResponse = {
  razorpay_order_id: string;
  razorpay_payment_id: string;
  razorpay_signature: string;
};

type RazorpayInstance = {
  open: () => void;
  on: (event: "payment.failed", cb: (r: { error?: { description?: string } }) => void) => void;
};

declare global {
  interface Window {
    Razorpay?: new (options: Record<string, unknown>) => RazorpayInstance;
  }
}

const RAZORPAY_JS = "https://checkout.razorpay.com/v1/checkout.js";

function loadRazorpay() {
  return new Promise<void>((resolve, reject) => {
    if (window.Razorpay) return resolve();
    const script = document.createElement("script");
    script.src = RAZORPAY_JS;
    script.onload = () => resolve();
    script.onerror = () => reject(new Error("Could not reach the payment page. Check your internet and try again."));
    document.body.appendChild(script);
  });
}

/** Calls the `checkout` Edge Function — the only place that touches money. */
async function callCheckout(token: string, body: Record<string, unknown>) {
  const res = await fetch(`${process.env.NEXT_PUBLIC_SUPABASE_URL}/functions/v1/checkout`, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${token}`,
      apikey: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(body),
  });
  const data = await res.json().catch(() => ({}));
  if (!res.ok) {
    throw new Error(
      res.status === 404 && data?.code === "NOT_FOUND"
        ? "Payments are not set up yet. Please try again later."
        : (data?.error ?? "Something went wrong. Nothing was charged — please try again."),
    );
  }
  return data as Record<string, unknown>;
}

/**
 * One-page checkout: what you are buying, what it costs, one Pay button.
 * Razorpay's own window then offers UPI, cards, net banking and wallets, and
 * the server verifies the payment before the course unlocks.
 */
export function CheckoutView({ enrolled, initialLanguage, student, course }: Props) {
  const router = useRouter();
  const [language, setLanguage] = useState<CourseLanguage>(initialLanguage);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [receipt, setReceipt] = useState<Receipt | null>(null);

  const discount = Math.max(0, course.originalPrice - course.price);

  async function pay() {
    if (busy) return;
    setBusy(true);
    setError(null);
    try {
      if (!course.id) throw new Error("This course is not on sale right now.");
      const supabase = createBrowserClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
      );
      const { data } = await supabase.auth.getSession();
      const token = data.session?.access_token;
      if (!token) {
        router.push(`/login?next=${encodeURIComponent(`/checkout/${course.slug}`)}`);
        return;
      }

      // Remember the language the student studies in; it never blocks paying.
      const userId = data.session?.user.id;
      if (userId) {
        void supabase
          .from("student_profiles")
          .upsert({ user_id: userId, medium: language }, { onConflict: "user_id" })
          .then(() => undefined);
      }

      const order = await callCheckout(token, { action: "create", course_id: course.id });
      const orderId = String(order.order_id);
      const amount = Number(order.amount_inr ?? course.price);

      if (order.test_mode === true) {
        await callCheckout(token, { action: "complete_test", order_id: orderId });
        setReceipt({ orderId, amount, testMode: true, language });
        return;
      }

      await loadRazorpay();
      await new Promise<void>((resolve, reject) => {
        const rzp = new window.Razorpay!({
          key: order.key_id,
          order_id: order.razorpay_order_id,
          amount: amount * 100,
          currency: order.currency ?? "INR",
          name: "AB Academy",
          description: course.title,
          image: `${window.location.origin}/images/logo.png`,
          prefill: order.prefill ?? {},
          theme: { color: "#B4521A" },
          retry: { enabled: true, max_count: 2 },
          modal: {
            ondismiss: () => reject(new Error("Payment cancelled. Nothing was charged.")),
          },
          handler: async (r: RazorpayResponse) => {
            try {
              await callCheckout(token, {
                action: "verify",
                order_id: orderId,
                razorpay_order_id: r.razorpay_order_id,
                razorpay_payment_id: r.razorpay_payment_id,
                razorpay_signature: r.razorpay_signature,
              });
              setReceipt({ orderId, amount, testMode: false, language });
              resolve();
            } catch {
              reject(
                new Error(
                  `Your payment went through and is being confirmed. The course unlocks within a few minutes — if it doesn't, write to ${CONTACT.email} with order ${orderId}.`,
                ),
              );
            }
          },
        });
        rzp.on("payment.failed", (r) =>
          reject(new Error(r.error?.description ?? "Payment failed. Nothing was charged.")),
        );
        rzp.open();
      });
    } catch (e) {
      setError(e instanceof Error ? e.message : "Something went wrong. Please try again.");
    } finally {
      setBusy(false);
    }
  }

  if (receipt) return <Success course={course} receipt={receipt} />;

  const payLabel = busy ? "Opening secure payment…" : `Pay ${formatInr(course.price)}`;

  return (
    <>
      <div className="mx-auto grid w-full max-w-[1080px] flex-1 items-start gap-8 px-4 pb-32 pt-8 sm:px-6 md:grid-cols-[minmax(0,1fr)_380px] md:pb-20 md:pt-12">
        {/* What you are buying */}
        <div>
          <Link href={`/course/${course.slug}`} className="text-sm font-semibold text-clay hover:underline">
            ← Back to course
          </Link>
          <p className="kicker mt-6 text-clay">Checkout</p>
          <h1 className="mt-2 font-serif text-[44px] leading-none tracking-[-0.02em] text-coal sm:text-[56px]">
            Complete your enrolment.
          </h1>

          <section className="mt-8 overflow-hidden rounded-[22px] border border-sand bg-cream">
            <div className="flex gap-4 p-5 sm:gap-5 sm:p-6">
              <div className="relative size-[84px] shrink-0 overflow-hidden rounded-2xl bg-sand sm:size-[104px]">
                {course.art ? (
                  <Image src={course.art} alt="" fill sizes="104px" className="object-cover" />
                ) : null}
              </div>
              <div className="min-w-0">
                <p className="text-xs font-bold uppercase tracking-[0.14em] text-clay">Class 12 · Bihar Board</p>
                <h2 className="mt-1.5 text-xl font-semibold leading-snug text-coal sm:text-[22px]">{course.title}</h2>
                <p className="mt-1 text-[15px] text-taupe">
                  with {course.teacher} · in {language}
                </p>
              </div>
            </div>
            <div className="border-t border-sand px-5 py-5 sm:px-6">
              <p className="text-xs font-bold uppercase tracking-[0.14em] text-taupe">Study language</p>
              <LanguageToggle value={language} onChange={setLanguage} />
            </div>
            <ul className="grid gap-3 border-t border-sand px-5 py-5 text-[15px] text-coal sm:grid-cols-2 sm:px-6">
              {[
                "1 lecture + 1 practice session per chapter",
                `Live doubt sessions with ${course.teacher}`,
                "On the website and the AB Academy app",
                `Access ${course.validity.charAt(0).toLowerCase()}${course.validity.slice(1)}`,
              ].map((item) => (
                <li key={item} className="flex items-start gap-2.5">
                  <span className="mt-0.5">
                    <CheckBadge size={18} />
                  </span>
                  {item}
                </li>
              ))}
            </ul>
          </section>

          <section className="mt-4 flex items-center justify-between gap-4 rounded-[22px] border border-sand bg-cream px-5 py-4 sm:px-6">
            <div className="min-w-0">
              <p className="text-xs font-bold uppercase tracking-[0.14em] text-taupe">Buying as</p>
              <p className="mt-1 truncate text-[15px] font-semibold text-coal">
                {student.name}
                {student.contact && student.contact !== student.name ? (
                  <span className="font-normal text-taupe"> · {student.contact}</span>
                ) : null}
              </p>
            </div>
            <span className="hidden shrink-0 text-[13px] text-taupe sm:inline">Course unlocks on this account</span>
          </section>
        </div>

        {/* Price and pay */}
        <aside className="rounded-[22px] border border-sand bg-cream p-5 sm:p-6 md:sticky md:top-8 md:mt-[183px]">
          <h2 className="text-xs font-bold uppercase tracking-[0.14em] text-taupe">Order summary</h2>
          <dl className="mt-4 flex flex-col gap-3 text-[15px] text-coal">
            <div className="flex justify-between">
              <dt>Course price</dt>
              <dd>{formatInr(course.originalPrice)}</dd>
            </div>
            {discount > 0 ? (
              <div className="flex justify-between">
                <dt>Discount</dt>
                <dd className="font-semibold text-success">− {formatInr(discount)}</dd>
              </div>
            ) : null}
            <div className="flex items-end justify-between border-t border-sand pt-4">
              <dt className="font-semibold">Total</dt>
              <dd className="font-serif text-[40px] leading-none">{formatInr(course.price)}</dd>
            </div>
            <p className="-mt-1 text-right text-xs text-taupe">One-time payment</p>
          </dl>

          {enrolled ? (
            <Enrolled />
          ) : (
            <>
              {error ? (
                <p role="alert" className="mt-5 rounded-xl border border-[#f2d6d6] bg-[#fdf1f1] px-4 py-3 text-sm leading-[1.5] text-[#9b2c2c]">
                  {error}
                </p>
              ) : null}
              <button
                type="button"
                onClick={pay}
                disabled={busy}
                className="mt-5 hidden h-14 w-full items-center justify-center gap-2 rounded-full bg-clay text-base font-semibold text-white transition hover:bg-coal disabled:cursor-wait disabled:opacity-70 md:flex"
              >
                {payLabel}
              </button>
              <TrustNotes />
            </>
          )}
        </aside>
      </div>

      {/* Phones: the pay button stays in reach. */}
      {enrolled ? null : (
        <div className="fixed inset-x-0 bottom-0 z-40 border-t border-sand bg-cream/95 px-4 pb-[calc(12px+env(safe-area-inset-bottom))] pt-3 backdrop-blur md:hidden">
          <div className="flex items-center gap-4">
            <div>
              <p className="text-xs text-taupe">Total</p>
              <p className="font-serif text-[28px] leading-none text-coal">{formatInr(course.price)}</p>
            </div>
            <button
              type="button"
              onClick={pay}
              disabled={busy}
              className="h-[52px] flex-1 rounded-full bg-clay text-[15px] font-semibold text-white disabled:opacity-70"
            >
              {busy ? "Opening…" : "Pay securely"}
            </button>
          </div>
        </div>
      )}
    </>
  );
}

function TrustNotes() {
  return (
    <div className="mt-5 flex flex-col gap-3 text-[13px] leading-[1.5] text-taupe">
      <div className="flex flex-wrap gap-1.5">
        {["UPI", "Cards", "Net banking", "Wallets"].map((m) => (
          <span key={m} className="rounded-full border border-sand bg-paper px-2.5 py-1 text-xs font-semibold text-coal">
            {m}
          </span>
        ))}
      </div>
      <p>Payments are processed securely by Razorpay. We never see your card or UPI details.</p>
      <p>
        7-day refund if you&apos;ve watched 3 lectures or fewer. By paying you agree to our{" "}
        <Link href="/terms" className="font-semibold text-clay hover:underline">
          Terms
        </Link>{" "}
        and{" "}
        <Link href="/refund" className="font-semibold text-clay hover:underline">
          Refund policy
        </Link>
        .
      </p>
      <p>
        Need help?{" "}
        <a href={`mailto:${CONTACT.email}`} className="font-semibold text-clay hover:underline">
          {CONTACT.email}
        </a>
      </p>
    </div>
  );
}

function Enrolled() {
  return (
    <div className="mt-5 flex flex-col gap-3">
      <p className="rounded-xl bg-[#e9f6ee] px-4 py-3 text-sm font-semibold text-[#1d6b3d]">
        You&apos;re already enrolled in this course.
      </p>
      <Link
        href="/my-courses"
        className="flex h-14 items-center justify-center rounded-full bg-clay text-base font-semibold text-white hover:bg-coal"
      >
        Go to my courses
      </Link>
    </div>
  );
}

function Success({ course, receipt }: { course: Props["course"]; receipt: Receipt }) {
  return (
    <div className="mx-auto w-full max-w-[560px] px-4 py-14 text-center sm:px-6 sm:py-20">
      <span className="mx-auto flex size-16 items-center justify-center rounded-full bg-[#e9f6ee]">
        <CheckBadge size={34} />
      </span>
      <p className="kicker mt-6 text-clay">Payment successful</p>
      <h1 className="mt-2 font-serif text-[44px] leading-none tracking-[-0.02em] text-coal">You&apos;re in.</h1>
      <p className="mt-3 text-base text-taupe">{course.title} is now unlocked on your account.</p>
      <dl className="mt-8 divide-y divide-sand rounded-[22px] border border-sand bg-cream text-left text-[15px]">
        {[
          ["Order ID", <span key="id" className="font-mono text-sm text-coal">{receipt.orderId.slice(0, 8).toUpperCase()}</span>],
          ["Amount paid", <span key="amt" className="font-semibold text-coal">{formatInr(receipt.amount)}</span>],
          ["Language", <span key="l" className="font-semibold text-coal">{receipt.language}</span>],
          ["Access", <span key="v" className="font-semibold text-coal">{course.validity}</span>],
        ].map(([label, value]) => (
          <div key={String(label)} className="flex justify-between gap-4 px-5 py-4">
            <dt className="text-taupe">{label}</dt>
            <dd>{value}</dd>
          </div>
        ))}
      </dl>
      {receipt.testMode ? (
        <p className="mt-4 rounded-xl bg-[#fff6e5] px-4 py-2.5 text-xs text-coal">
          Test mode — payments are not connected yet, so nothing was charged.
        </p>
      ) : null}
      <div className="mt-8 flex flex-col justify-center gap-3 sm:flex-row">
        <Link
          href="/my-courses"
          className="flex h-[52px] items-center justify-center rounded-full bg-clay px-7 text-[15px] font-semibold text-white hover:bg-coal"
        >
          Start learning
        </Link>
        <Link
          href="/dashboard"
          className="flex h-[52px] items-center justify-center rounded-full border border-sand px-7 text-[15px] font-semibold text-coal hover:bg-cream"
        >
          Go to dashboard
        </Link>
      </div>
    </div>
  );
}
