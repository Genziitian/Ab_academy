import Image from "next/image";
import Link from "next/link";
import { ButtonLink } from "@/components/ButtonLink";
import { CourseCard } from "@/components/CourseCard";
import { listCourses } from "@/lib/catalog";

const features = [
  {
    title: "Live Classes",
    body: "Join scheduled sessions with expert teachers in real time.",
    tint: "bg-[#e8f0ff] text-primary",
    icon: "live",
  },
  {
    title: "Recorded Lectures",
    body: "Rewatch every lecture anytime if you miss a class.",
    tint: "bg-[#fff1e8] text-orange",
    icon: "record",
  },
  {
    title: "Study Notes",
    body: "Chapter PDFs and important questions ready to revise.",
    tint: "bg-[#f1ecff] text-violet",
    icon: "notes",
  },
  {
    title: "Tests & Practice",
    body: "Stay exam-ready with structured practice (coming soon).",
    tint: "bg-[#e8fff6] text-teal",
    icon: "test",
  },
];

const classCards = [
  {
    level: 9,
    title: "Class 9",
    tagline: "Strong foundations for the years ahead",
    bg: "bg-[#fff4ec]",
    iconBg: "bg-[#ff8a3d]",
  },
  {
    level: 10,
    title: "Class 10",
    tagline: "Board preparation with live guidance",
    bg: "bg-[#eef3ff]",
    iconBg: "bg-[#2962ff]",
  },
  {
    level: 11,
    title: "Class 11",
    tagline: "Stream-ready Science, Commerce & Arts",
    bg: "bg-[#f4efff]",
    iconBg: "bg-[#7c5cff]",
  },
  {
    level: 12,
    title: "Class 12",
    tagline: "Board + entrance focused batches",
    bg: "bg-[#eefbf6]",
    iconBg: "bg-[#14b8a6]",
  },
];

export default async function HomePage() {
  const featured = (await listCourses()).slice(0, 3);

  return (
    <>
      {/* Hero — matches UI kit layout */}
      <section className="relative overflow-hidden bg-white">
        <div className="mx-auto grid max-w-6xl items-center gap-10 px-4 py-10 sm:px-6 lg:grid-cols-2 lg:gap-8 lg:py-16">
          <div className="order-2 lg:order-1">
            <p className="animate-fade-up text-sm font-semibold uppercase tracking-[0.16em] text-primary">
              Akhand Bharat Academy
            </p>
            <h1 className="animate-fade-up-delay mt-3 max-w-xl text-[2rem] font-extrabold leading-[1.15] tracking-tight text-navy sm:text-5xl">
              Learn Today Build a{" "}
              <span className="text-primary">Brighter Tomorrow</span>
            </h1>
            <p className="animate-fade-up-delay-2 mt-4 max-w-lg text-sm leading-relaxed text-muted sm:text-base">
              Live classes, recorded lectures and notes for Classes 9–12.
              Starting with Bihar Board — more boards and domains coming soon.
            </p>

            <ul className="animate-fade-up-delay-2 mt-6 space-y-2.5 text-sm font-medium text-navy">
              <li className="flex items-center gap-2.5">
                <CheckIcon /> Board focused learning
              </li>
              <li className="flex items-center gap-2.5">
                <CheckIcon /> Expert teachers
              </li>
              <li className="flex items-center gap-2.5">
                <CheckIcon /> Affordable learning
              </li>
            </ul>

            <div className="animate-fade-up-delay-2 mt-8 flex flex-wrap gap-3">
              <ButtonLink href="/login">Get Started</ButtonLink>
              <ButtonLink href="/courses" variant="secondary">
                Explore Courses
              </ButtonLink>
            </div>
          </div>

          <div className="relative order-1 mx-auto w-full max-w-md lg:order-2 lg:max-w-none">
            <div className="absolute -right-6 top-6 h-64 w-64 rounded-[40%] bg-[#dbe7ff] sm:-right-10 sm:h-80 sm:w-80 lg:right-0" />
            <div className="absolute -bottom-4 -left-4 h-28 w-28 rounded-full bg-primary/10 blur-xl" />

            <div className="animate-fade-up relative overflow-hidden rounded-[1.75rem]">
              <Image
                src="/images/hero-students.png"
                alt="Students learning with Akhand Bharat Academy"
                width={720}
                height={560}
                priority
                className="relative z-[1] h-auto w-full object-cover"
              />
            </div>

            <div className="animate-float absolute -left-2 top-8 z-[2] max-w-[11rem] rounded-2xl bg-white px-3.5 py-3 text-xs font-semibold leading-snug text-navy shadow-[var(--shadow-soft)] sm:left-0 sm:top-12 sm:max-w-[13rem] sm:text-sm">
              Better Students.
              <br />
              Brighter Futures.
              <span className="absolute -bottom-2 left-8 h-4 w-4 rotate-45 bg-white" />
            </div>
          </div>
        </div>
      </section>

      {/* Feature cards — icon style like kit */}
      <section className="bg-surface-soft">
        <div className="mx-auto max-w-6xl px-4 py-12 sm:px-6 sm:py-16">
          <div className="mx-auto max-w-2xl text-center">
            <h2 className="text-2xl font-extrabold tracking-tight text-navy sm:text-3xl">
              Everything you need to succeed
            </h2>
            <p className="mt-3 text-sm text-muted sm:text-base">
              One simple path — join class, revise, and track your progress.
            </p>
          </div>

          <div className="mt-10 grid gap-4 sm:grid-cols-2 lg:grid-cols-4 lg:gap-5">
            {features.map((feature) => (
              <article
                key={feature.title}
                className="rounded-2xl border border-border bg-white p-5 shadow-[var(--shadow-card)] transition hover:-translate-y-0.5 hover:shadow-[var(--shadow-soft)]"
              >
                <div
                  className={`mb-4 inline-flex h-12 w-12 items-center justify-center rounded-2xl ${feature.tint}`}
                >
                  <FeatureIcon name={feature.icon} />
                </div>
                <h3 className="text-base font-bold text-navy">{feature.title}</h3>
                <p className="mt-2 text-sm leading-relaxed text-muted">
                  {feature.body}
                </p>
              </article>
            ))}
          </div>
        </div>
      </section>

      {/* Choose your class — pastel cards */}
      <section className="bg-white">
        <div className="mx-auto max-w-6xl px-4 py-12 sm:px-6 sm:py-16">
          <div className="mx-auto max-w-2xl text-center">
            <h2 className="text-2xl font-extrabold tracking-tight text-navy sm:text-3xl">
              Choose Your Class
            </h2>
            <p className="mt-3 text-sm text-muted sm:text-base">
              Bihar Board Classes 9–12 available now. More programmes launching
              soon.
            </p>
          </div>

          <div className="mt-10 grid grid-cols-2 gap-3 sm:gap-5 lg:grid-cols-4">
            {classCards.map((item) => (
              <Link
                key={item.level}
                href={`/courses?class=${item.level}`}
                className={`rounded-2xl ${item.bg} p-4 transition duration-300 hover:-translate-y-1 hover:shadow-[var(--shadow-soft)] sm:p-6`}
              >
                <span
                  className={`inline-flex h-11 w-11 items-center justify-center rounded-2xl text-white sm:h-12 sm:w-12 ${item.iconBg}`}
                >
                  <BookIcon />
                </span>
                <h3 className="mt-4 text-lg font-extrabold text-navy sm:text-xl">
                  {item.title}
                </h3>
                <p className="mt-1.5 text-xs leading-relaxed text-muted sm:text-sm">
                  {item.tagline}
                </p>
              </Link>
            ))}
          </div>
        </div>
      </section>

      {/* Popular courses */}
      <section className="bg-surface-soft">
        <div className="mx-auto max-w-6xl px-4 py-12 sm:px-6 sm:py-16">
          <div className="flex flex-wrap items-end justify-between gap-4">
            <div>
              <h2 className="text-2xl font-extrabold tracking-tight text-navy sm:text-3xl">
                Popular Courses
              </h2>
              <p className="mt-2 text-sm text-muted sm:text-base">
                Complete batches and subject courses to get started.
              </p>
            </div>
            <ButtonLink
              href="/courses"
              variant="secondary"
              className="hidden sm:inline-flex"
            >
              View all courses
            </ButtonLink>
          </div>
          <div className="mt-8 grid gap-4 sm:mt-10 sm:grid-cols-2 sm:gap-6 lg:grid-cols-3">
            {featured.map((course) => (
              <CourseCard key={course.slug} course={course} />
            ))}
          </div>
        </div>
      </section>

      {/* CTA band */}
      <section className="bg-white">
        <div className="mx-auto max-w-6xl px-4 py-12 sm:px-6 sm:py-16">
          <div className="overflow-hidden rounded-[1.75rem] bg-gradient-to-br from-primary to-primary-dark px-6 py-10 text-white sm:px-10 sm:py-12">
            <p className="font-hindi text-sm text-white/75">
              आज शुरू करें — कल का आत्मविश्वास बनाएँ।
            </p>
            <h2 className="mt-3 max-w-xl text-2xl font-extrabold sm:text-3xl">
              Ready for your next live class?
            </h2>
            <p className="mt-3 max-w-lg text-sm text-white/80 sm:text-base">
              Join Akhand Bharat Academy — start with Bihar Board, grow into more
              domains with us.
            </p>
            <div className="mt-8">
              <ButtonLink
                href="/login"
                variant="secondary"
                className="border-transparent bg-white text-primary hover:bg-primary-soft"
              >
                Create free account
              </ButtonLink>
            </div>
          </div>
        </div>
      </section>
    </>
  );
}

function CheckIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 18 18" fill="none" aria-hidden>
      <circle cx="9" cy="9" r="9" fill="#22c55e" />
      <path
        d="M5 9.2 7.6 11.7 13 6.4"
        stroke="white"
        strokeWidth="1.8"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function BookIcon() {
  return (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" aria-hidden>
      <path
        d="M4 5.5A2.5 2.5 0 0 1 6.5 3H20v16H6.5A2.5 2.5 0 0 0 4 21.5V5.5Z"
        stroke="currentColor"
        strokeWidth="1.8"
      />
      <path d="M4 19.5h16" stroke="currentColor" strokeWidth="1.8" />
    </svg>
  );
}

function FeatureIcon({ name }: { name: string }) {
  const common = {
    width: 22,
    height: 22,
    viewBox: "0 0 24 24",
    fill: "none",
    "aria-hidden": true as const,
  };

  if (name === "live") {
    return (
      <svg {...common}>
        <circle cx="12" cy="12" r="3" fill="currentColor" />
        <path
          d="M5.5 8.5a8 8 0 0 1 0 7M18.5 8.5a8 8 0 0 0 0 7"
          stroke="currentColor"
          strokeWidth="1.8"
          strokeLinecap="round"
        />
      </svg>
    );
  }
  if (name === "record") {
    return (
      <svg {...common}>
        <rect
          x="3"
          y="6"
          width="14"
          height="12"
          rx="2"
          stroke="currentColor"
          strokeWidth="1.8"
        />
        <path
          d="m17 10 4-2v8l-4-2"
          stroke="currentColor"
          strokeWidth="1.8"
          strokeLinejoin="round"
        />
      </svg>
    );
  }
  if (name === "notes") {
    return (
      <svg {...common}>
        <path
          d="M7 3h8l4 4v14H7V3Z"
          stroke="currentColor"
          strokeWidth="1.8"
          strokeLinejoin="round"
        />
        <path
          d="M15 3v4h4M9 12h6M9 16h6"
          stroke="currentColor"
          strokeWidth="1.8"
          strokeLinecap="round"
        />
      </svg>
    );
  }
  return (
    <svg {...common}>
      <path
        d="M4 5h16v4H4V5Zm0 7h10v7H4v-7Zm12 0h4v7h-4v-7Z"
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinejoin="round"
      />
    </svg>
  );
}
