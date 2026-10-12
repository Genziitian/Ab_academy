import Image from "next/image";
import Link from "next/link";

export const metadata = {
  title: "For Students",
  description: "How learning works at Akhand Bharat Academy.",
};

const steps = [
  {
    title: "Create your profile",
    body: "Login with mobile OTP and select your class, medium and stream.",
  },
  {
    title: "Choose a course",
    body: "Browse full-stream crash courses or single subjects. Bihar Board is available now.",
  },
  {
    title: "Learn every day",
    body: "Join live classes, watch recordings, download notes and follow your calendar.",
  },
];

const included = [
  "Live class schedule with reminders",
  "Recordings attached to each chapter",
  "PDF notes with secure downloads",
  "Continue-learning from last position",
];

export default function ForStudentsPage() {
  return (
    <>
      <section className="mx-auto grid max-w-[1200px] items-center gap-14 px-4 pb-14 pt-14 sm:px-6 sm:pt-[72px] lg:grid-cols-2">
        <div>
          <p className="eyebrow">For students</p>
          <h1 className="mt-3 text-[36px] font-bold leading-[1.1] tracking-[-0.025em] text-balance text-navy sm:text-[46px]">
            A calm path from login to lesson
          </h1>
          <p className="mt-[18px] text-lg leading-[1.6] text-ink">
            No marketplace clutter. Just your classes, your progress and what to
            study next.
          </p>
          <div className="mt-7 flex flex-wrap gap-3">
            <Link
              href="/login"
              className="flex h-12 items-center rounded-lg bg-primary px-6 text-[15px] font-semibold text-white hover:bg-primary-dark"
            >
              Create your profile
            </Link>
            <Link
              href="/courses"
              className="flex h-12 items-center rounded-lg border border-primary-line px-6 text-[15px] font-semibold text-primary hover:bg-primary-soft"
            >
              Browse courses
            </Link>
          </div>
        </div>
        <div className="aspect-[4/3] overflow-hidden rounded-2xl bg-[#eef3ff]">
          <Image
            src="/images/feature-live-class.png"
            alt="Live class"
            width={800}
            height={600}
            className="size-full object-cover"
          />
        </div>
      </section>

      <section className="border-y border-border bg-surface-soft">
        <div className="mx-auto max-w-[1200px] px-4 py-16 sm:px-6">
          <h2 className="text-[28px] font-bold tracking-[-0.02em] text-navy">How it works</h2>
          <ol className="mt-8 grid gap-5 md:grid-cols-3">
            {steps.map((step, index) => (
              <li key={step.title} className="rounded-xl border border-border bg-white p-7">
                <p className="text-[40px] font-bold tracking-[-0.02em] text-primary-line">
                  {String(index + 1).padStart(2, "0")}
                </p>
                <h3 className="mt-3.5 text-[19px] font-semibold text-navy">{step.title}</h3>
                <p className="mt-2 text-[15px] leading-[1.6] text-muted">{step.body}</p>
              </li>
            ))}
          </ol>
        </div>
      </section>

      <section className="mx-auto grid max-w-[1200px] gap-12 px-4 pb-20 pt-16 sm:px-6 lg:grid-cols-[320px_minmax(0,1fr)]">
        <div>
          <h2 className="text-[28px] font-bold tracking-[-0.02em] text-navy">
            What you get in every course
          </h2>
          <Link
            href="/courses"
            className="mt-5 inline-flex h-11 items-center rounded-lg bg-primary px-5 text-sm font-semibold text-white hover:bg-primary-dark"
          >
            Browse courses
          </Link>
        </div>
        <div className="grid gap-px overflow-hidden rounded-xl border border-border bg-border sm:grid-cols-2">
          {included.map((item) => (
            <div key={item} className="flex gap-3 bg-white p-6">
              <span className="font-bold text-success">✓</span>
              <span className="text-[15px] text-navy">{item}</span>
            </div>
          ))}
        </div>
      </section>
    </>
  );
}
