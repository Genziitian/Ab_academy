"use client";

import { createBrowserClient } from "@supabase/ssr";
import Image from "next/image";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { LanguageToggle } from "@/components/LanguagePicker";
import { Check, btn } from "@/components/ui";
import { useT } from "@/lib/i18n/client";
import type { Dict } from "@/lib/i18n/dictionaries";
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

function loadRazorpay(message: string) {
  return new Promise<void>((resolve, reject) => {
    if (window.Razorpay) return resolve();
    const script = document.createElement("script");
    script.src = RAZORPAY_JS;
    script.onload = () => resolve();
    script.onerror = () => reject(new Error(message));
    document.body.appendChild(script);
  });
}

/** Calls the site's payment API (/api/create-order, /api/verify-payment). */
async function callPayments(path: string, token: string, body: Record<string, unknown>, fallback: string) {
  const res = await fetch(path, {
    method: "POST",
    headers: { Authorization: `Bearer ${token}`, "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
  const data = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(data?.error ?? fallback);
  return data as Record<string, unknown>;
}

/**
 * One-page checkout: what you are buying, what it costs, one Pay button.
 * Razorpay's own window then offers UPI, cards, net banking and wallets, and
 * the server verifies the payment before the course unlocks.
 */
export function CheckoutView({ enrolled, initialLanguage, student, course }: Props) {
  const t = useT();
  const c = t.checkout;
  const router = useRouter();
  const [language, setLanguage] = useState<CourseLanguage>(initialLanguage);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [receipt, setReceipt] = useState<Receipt | null>(null);

  const discount = Math.max(0, course.originalPrice - course.price);
  const langName = (l: CourseLanguage) => (l === "Hindi" ? t.common.hindi : t.common.hinglish);

  async function pay() {
    if (busy) return;
    setBusy(true);
    setError(null);
    try {
      if (!course.id) throw new Error(c.errors.notOnSale);
      const supabase = createBrowserClient(process.env.NEXT_PUBLIC_SUPABASE_URL!, process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!);
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

      const order = await callPayments("/api/create-order", token, { course_id: course.id }, c.errors.generic);
      const receiptId = String(order.receipt);
      const amountPaise = Number(order.amount);

      await loadRazorpay(c.errors.load);
      await new Promise<void>((resolve, reject) => {
        let lastFailure: string | null = null;
        const rzp = new window.Razorpay!({
          key: order.key_id,
          order_id: order.order_id,
          amount: amountPaise,
          currency: order.currency ?? "INR",
          name: "AB Academy",
          description: course.title,
          image: `${window.location.origin}/images/logo.png`,
          prefill: order.prefill ?? {},
          notes: { language },
          theme: { color: "#171511" },
          retry: { enabled: true, max_count: 3 },
          modal: {
            // Closing the window after a failed try reports that failure.
            ondismiss: () => reject(new Error(lastFailure ?? c.errors.cancelled)),
          },
          handler: async (r: RazorpayResponse) => {
            try {
              await callPayments(
                "/api/verify-payment",
                token,
                {
                  razorpay_order_id: r.razorpay_order_id,
                  razorpay_payment_id: r.razorpay_payment_id,
                  razorpay_signature: r.razorpay_signature,
                },
                c.errors.generic,
              );
              setReceipt({ orderId: receiptId, amount: amountPaise / 100, testMode: String(order.key_id).startsWith("rzp_test_"), language });
              resolve();
            } catch {
              reject(new Error(c.errors.confirming(CONTACT.email, r.razorpay_payment_id)));
            }
          },
        });
        // Razorpay keeps its window open so the student can retry.
        rzp.on("payment.failed", (r) => {
          lastFailure = c.errors.failed(r.error?.description ?? c.errors.failedDefault);
        });
        rzp.open();
      });
    } catch (e) {
      setError(e instanceof Error ? e.message : c.errors.generic);
    } finally {
      setBusy(false);
    }
  }

  if (receipt) return <Success course={course} receipt={receipt} t={t} langName={langName} />;

  return (
    <>
      <div className="mx-auto grid w-full max-w-[1120px] flex-1 items-start gap-8 px-4 pb-32 pt-8 sm:px-6 md:grid-cols-[minmax(0,1fr)_380px] md:pb-20 md:pt-12">
        <div>
          <Link href={`/course/${course.slug}`} className="text-sm text-ab-ink-2 hover:text-ab-ink">
            ← {c.back}
          </Link>
          <p className="ab-eyebrow mt-6">{c.eyebrow}</p>
          <h1 className="ab-display mt-2 text-[36px] sm:text-[44px]">{c.title}</h1>

          <section className="mt-8 overflow-hidden rounded-2xl border border-ab-rule bg-ab-panel">
            <div className="flex gap-4 p-5 sm:gap-5 sm:p-6">
              <div className="relative size-[84px] shrink-0 overflow-hidden rounded-xl bg-ab-tray sm:size-[96px]">
                {course.art ? <Image src={course.art} alt="" fill sizes="96px" className="object-cover" /> : null}
              </div>
              <div className="min-w-0">
                <p className="text-[13px] text-ab-ink-3">{c.meta}</p>
                <h2 className="ab-title mt-1 text-xl sm:text-[22px]">{course.title}</h2>
                <p className="mt-1 text-[15px] text-ab-ink-2">{c.withIn(course.teacher, langName(language))}</p>
              </div>
            </div>
            <div className="border-t border-ab-rule px-5 py-5 sm:px-6">
              <p className="text-sm font-medium text-ab-ink">{c.studyLanguage}</p>
              <LanguageToggle value={language} onChange={setLanguage} />
            </div>
            <ul className="grid gap-3 border-t border-ab-rule px-5 py-5 text-[15px] text-ab-ink sm:grid-cols-2 sm:px-6">
              {c.includes(course.teacher, course.validity).map((item) => (
                <li key={item} className="flex items-start gap-2.5">
                  <Check className="mt-1 text-ab-accent" />
                  {item}
                </li>
              ))}
            </ul>
          </section>

          <section className="mt-4 flex items-center justify-between gap-4 rounded-2xl border border-ab-rule bg-ab-panel px-5 py-4 sm:px-6">
            <div className="min-w-0">
              <p className="text-[13px] text-ab-ink-3">{c.buyingAs}</p>
              <p className="mt-0.5 truncate text-[15px] font-medium text-ab-ink">
                {student.name}
                {student.contact && student.contact !== student.name ? <span className="font-normal text-ab-ink-2"> · {student.contact}</span> : null}
              </p>
            </div>
            <span className="hidden shrink-0 text-[13px] text-ab-ink-3 sm:inline">{c.unlocksHere}</span>
          </section>
        </div>

        <aside className="rounded-[22px] bg-ab-tray p-1.5 md:sticky md:top-8 md:mt-[150px]">
          <div className="rounded-[16px] border border-ab-rule bg-ab-panel p-5 sm:p-6">
            <h2 className="text-sm text-ab-ink-2">{c.summary}</h2>
            <dl className="mt-4 flex flex-col gap-3 text-[15px] text-ab-ink">
              <div className="flex justify-between">
                <dt className="text-ab-ink-2">{c.price}</dt>
                <dd className="ab-num">{formatInr(course.originalPrice)}</dd>
              </div>
              {discount > 0 ? (
                <div className="flex justify-between">
                  <dt className="text-ab-ink-2">{c.discount}</dt>
                  <dd className="ab-num text-ab-live">− {formatInr(discount)}</dd>
                </div>
              ) : null}
              <div className="flex items-end justify-between border-t border-ab-rule pt-4">
                <dt className="font-medium">{c.total}</dt>
                <dd className="ab-fig text-[36px] font-medium leading-none">{formatInr(course.price)}</dd>
              </div>
              <p className="-mt-1 text-right text-xs text-ab-ink-3">{c.oneTime}</p>
            </dl>

            {enrolled ? (
              <Enrolled t={t} />
            ) : (
              <>
                {error ? (
                  <p role="alert" className="mt-5 rounded-[10px] border border-[#f3cdc8] bg-ab-danger-soft px-4 py-3 text-sm leading-[1.5] text-ab-danger">
                    {error}
                  </p>
                ) : null}
                <button type="button" onClick={pay} disabled={busy} className={`${btn.primary} mt-5 !h-[52px] w-full max-md:!hidden`}>
                  {busy ? c.opening : c.pay(formatInr(course.price))}
                </button>
              </>
            )}
          </div>
          {enrolled ? null : <TrustNotes t={t} />}
        </aside>
      </div>

      {/* Phones: the pay button stays in reach. */}
      {enrolled ? null : (
        <div className="fixed inset-x-0 bottom-0 z-40 border-t border-ab-rule bg-ab-panel px-4 pb-[calc(12px+env(safe-area-inset-bottom))] pt-3 md:hidden">
          <div className="flex items-center gap-4">
            <div>
              <p className="text-xs text-ab-ink-3">{c.total}</p>
              <p className="ab-fig text-[26px] font-medium leading-none text-ab-ink">{formatInr(course.price)}</p>
            </div>
            <button type="button" onClick={pay} disabled={busy} className={`${btn.primary} !h-12 flex-1`}>
              {busy ? c.openingShort : c.payShort}
            </button>
          </div>
        </div>
      )}
    </>
  );
}

function TrustNotes({ t }: { t: Dict }) {
  const c = t.checkout;
  const link = "text-ab-ink underline decoration-ab-rule-strong underline-offset-2 hover:decoration-ab-ink";
  return (
    <div className="flex flex-col gap-3 px-4 py-4 text-[13px] leading-[1.55] text-ab-ink-2">
      <div className="flex flex-wrap gap-1.5">
        {c.methods.map((m) => (
          <span key={m} className="rounded-full border border-ab-rule bg-ab-panel px-2.5 py-0.5 text-xs text-ab-ink">
            {m}
          </span>
        ))}
      </div>
      <p>{c.razorpay}</p>
      <p>
        {c.refundPre}{" "}
        <Link href="/terms" className={link}>
          {c.terms}
        </Link>{" "}
        {c.and}{" "}
        <Link href="/refund" className={link}>
          {c.refundPolicy}
        </Link>
        .
      </p>
      <p>
        {c.needHelp}{" "}
        <a href={`mailto:${CONTACT.email}`} className={link}>
          {CONTACT.email}
        </a>
      </p>
    </div>
  );
}

function Enrolled({ t }: { t: Dict }) {
  return (
    <div className="mt-5 flex flex-col gap-3">
      <p className="rounded-[10px] border border-[#cfe5d7] bg-ab-live-soft px-4 py-3 text-sm text-ab-live">{t.checkout.enrolled}</p>
      <Link href="/my-courses" className={`${btn.primary} !h-12`}>
        {t.checkout.goToCourses}
      </Link>
    </div>
  );
}

function Success({
  course,
  receipt,
  t,
  langName,
}: {
  course: Props["course"];
  receipt: Receipt;
  t: Dict;
  langName: (l: CourseLanguage) => string;
}) {
  const c = t.checkout;
  return (
    <div className="mx-auto w-full max-w-[560px] px-4 py-14 text-center sm:px-6 sm:py-20">
      <span className="mx-auto flex size-14 items-center justify-center rounded-full bg-ab-live-soft text-ab-live">
        <Check size={26} />
      </span>
      <p className="ab-eyebrow mt-6">{c.successEyebrow}</p>
      <h1 className="ab-display mt-2 text-[44px]">{c.successTitle}</h1>
      <p className="mt-3 text-base text-ab-ink-2">{c.successBody(course.title)}</p>
      <dl className="mt-8 divide-y divide-ab-rule rounded-2xl border border-ab-rule bg-ab-panel text-left text-[15px]">
        {[
          [c.orderId, <span key="id" className="ab-num text-sm text-ab-ink">{receipt.orderId.slice(0, 8).toUpperCase()}</span>],
          [c.amount, <span key="amt" className="ab-num font-medium text-ab-ink">{formatInr(receipt.amount)}</span>],
          [c.language, <span key="l" className="font-medium text-ab-ink">{langName(receipt.language)}</span>],
          [c.access, <span key="v" className="font-medium text-ab-ink">{course.validity}</span>],
        ].map(([label, value]) => (
          <div key={String(label)} className="flex justify-between gap-4 px-5 py-4">
            <dt className="text-ab-ink-2">{label}</dt>
            <dd>{value}</dd>
          </div>
        ))}
      </dl>
      {receipt.testMode ? <p className="mt-4 rounded-[10px] border border-ab-rule bg-ab-canvas px-4 py-2.5 text-xs text-ab-ink-2">{c.testMode}</p> : null}
      <div className="mt-8 flex flex-col justify-center gap-3 sm:flex-row">
        <Link href="/my-courses" className={`${btn.primary} !h-12`}>
          {c.start}
        </Link>
        <Link href="/dashboard" className={`${btn.secondary} !h-12`}>
          {c.dashboard}
        </Link>
      </div>
    </div>
  );
}
