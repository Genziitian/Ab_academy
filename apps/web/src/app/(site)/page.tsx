import Image from "next/image";
import Link from "next/link";
import { FeaturedCarousel } from "@/components/FeaturedCarousel";
import {
  CheckBadge,
  LiveIcon,
  NotesIcon,
  TestIcon,
  VideoIcon,
} from "@/components/icons";
import { listCourses } from "@/lib/catalog";
import { Course, formatInr } from "@/lib/courses";

const features = [
  {
    title: "Live Classes",
    body: "Join scheduled sessions with expert teachers in real time.",
    tint: "bg-primary-soft text-primary",
    Icon: LiveIcon,
  },
  {
    title: "Recorded Lectures",
    body: "Rewatch every lecture anytime if you miss a class.",
    tint: "bg-amber-soft text-orange",
    Icon: VideoIcon,
  },
  {
    title: "Study Notes",
    body: "Chapter PDFs and important questions ready to revise.",
    tint: "bg-violet-soft text-violet",
    Icon: NotesIcon,
  },
  {
    title: "Tests & Practice",
    body: "Board-pattern tests every week to stay exam-ready.",
    tint: "bg-teal-soft text-teal",
    Icon: TestIcon,
  },
];

const streams = [
  {
    name: "Science (PCM + PCB)",
    subjects: "Physics · Chemistry · Maths · Biology",
    match: (c: Course) => c.subjects.some((s) => ["Physics", "Chemistry", "Biology"].includes(s)),
  },
  {
    name: "Commerce",
    subjects: "Accountancy · Business Studies · Economics",
    match: (c: Course) => c.subjects.includes("Accountancy"),
  },
  {
    name: "Arts",
    subjects: "History · Political Science · Geography",
    match: (c: Course) => c.subjects.includes("History"),
  },
];

const classCards = [
  { level: 12, title: "Class 12", tagline: "Board 2027 crash courses", color: "text-primary" },
  { level: 11, title: "Class 11", tagline: "Build a strong base for Class 12", color: "text-violet" },
];

/** "From ₹999" when a stream has several courses, the price when it has one. */
function streamPrice(courses: Course[]) {
  if (!courses.length) return "Coming soon";
  const min = Math.min(...courses.map((c) => c.price));
  return courses.length > 1 ? `From ${formatInr(min)}` : formatInr(min);
}

export default async function HomePage() {
  const all = await listCourses();
  const featured = [...all].sort(
    (a, b) => b.classLevel - a.classLevel || Number(!!b.bestseller) - Number(!!a.bestseller),
  );

  return (
    <>
      <section className="border-b border-border bg-white">
        <div className="mx-auto grid max-w-[1200px] items-center gap-14 px-4 pb-[72px] pt-12 sm:px-6 sm:pt-16 lg:grid-cols-2">
          <div>
            <p className="inline-flex items-center gap-2 whitespace-nowrap rounded-md bg-primary-soft px-3 py-1.5 text-[13px] font-semibold text-primary">
              <span className="size-1.5 rounded-full bg-primary" />
              Board 2027 crash courses now enrolling
            </p>
            <h1 className="mt-5 text-[38px] font-bold leading-[1.08] tracking-[-0.025em] text-balance text-navy sm:text-[52px]">
              Class 11 &amp; 12 <span className="text-primary">Crash Courses</span>{" "}
              for Bihar Board
            </h1>
            <p className="mt-5 max-w-[520px] text-lg leading-[1.6] text-pretty text-ink">
              Finish the full syllabus in 90 days with live classes, recorded
              lectures, chapter notes and board-pattern tests — Science,
              Commerce and Arts.
            </p>
            <div className="mt-8 flex flex-wrap gap-3">
              <Link
                href="/courses"
                className="flex h-12 items-center whitespace-nowrap rounded-lg bg-primary px-6 text-[15px] font-semibold text-white hover:bg-primary-dark"
              >
                Explore Crash Courses
              </Link>
              <Link
                href="/login"
                className="flex h-12 items-center whitespace-nowrap rounded-lg border border-primary-line px-6 text-[15px] font-semibold text-primary hover:bg-primary-soft"
              >
                Get Started Free
              </Link>
            </div>
            <div className="mt-10 flex flex-wrap gap-x-7 gap-y-3 border-t border-border pt-7">
              {["90-day board plan", "Expert teachers", "Hindi & English medium"].map(
                (item) => (
                  <div
                    key={item}
                    className="flex items-center gap-2 whitespace-nowrap text-sm font-medium text-navy"
                  >
                    <CheckBadge />
                    {item}
                  </div>
                ),
              )}
            </div>
          </div>

          <div className="relative">
            <div className="aspect-[9/7] overflow-hidden rounded-2xl bg-[#dbe7ff]">
              <Image
                src="/images/hero-students.png"
                alt="Students learning with Akhand Bharat Academy"
                width={900}
                height={700}
                priority
                className="size-full object-cover"
              />
            </div>
            <div className="absolute bottom-8 left-3 flex items-center gap-3 rounded-xl border border-border bg-white px-4 py-3.5 shadow-[var(--shadow-float)] sm:-left-4">
              <span className="shrink-0 whitespace-nowrap rounded bg-danger-soft px-2 py-[3px] text-[11px] font-bold tracking-[0.04em] text-danger">
                ● LIVE
              </span>
              <div>
                <p className="whitespace-nowrap text-sm font-semibold text-navy">
                  Class 12 Physics · Electrostatics
                </p>
                <p className="mt-0.5 text-xs text-muted">Amit Sir · Today 6:00 PM</p>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section className="bg-surface-soft">
        <div className="mx-auto max-w-[1200px] px-4 py-[72px] sm:px-6">
          <div className="flex flex-wrap items-end justify-between gap-x-6 gap-y-4">
            <div className="max-w-[560px]">
              <p className="eyebrow">Inside every crash course</p>
              <h2 className="mt-2.5 text-[28px] font-bold tracking-[-0.02em] text-navy sm:text-[34px]">
                Everything you need to succeed
              </h2>
            </div>
            <p className="max-w-[380px] text-base text-muted">
              One simple path — join class, revise, and track your progress.
            </p>
          </div>
          <div className="mt-9 grid gap-px overflow-hidden rounded-xl border border-border bg-border sm:grid-cols-2 lg:grid-cols-4">
            {features.map(({ title, body, tint, Icon }) => (
              <article key={title} className="bg-white p-7">
                <span
                  className={`flex size-11 items-center justify-center rounded-[10px] ${tint}`}
                >
                  <Icon size={22} />
                </span>
                <h3 className="mt-5 text-[17px] font-semibold text-navy">{title}</h3>
                <p className="mt-2 text-sm leading-[1.6] text-muted">{body}</p>
              </article>
            ))}
          </div>
        </div>
      </section>

      <section className="bg-white">
        <div className="mx-auto max-w-[1200px] px-4 py-[72px] sm:px-6">
          <FeaturedCarousel courses={featured} />
        </div>
      </section>

      <section className="bg-surface-soft">
        <div className="mx-auto max-w-[1200px] px-4 py-[72px] sm:px-6">
          <h2 className="text-[28px] font-bold tracking-[-0.02em] text-navy sm:text-[34px]">
            Choose your class &amp; stream
          </h2>
          <p className="mt-2.5 text-base text-muted">
            Bihar Board Class 11 and 12 crash courses available now.
          </p>
          <div className="mt-8 grid gap-5 md:grid-cols-2">
            {classCards.map((card) => {
              const ofClass = all.filter((c) => c.classLevel === card.level);
              return (
                <div
                  key={card.level}
                  className="rounded-xl border border-border bg-white p-7"
                >
                  <div className="flex items-baseline gap-3.5">
                    <span
                      className={`text-5xl font-bold leading-none tracking-[-0.03em] ${card.color}`}
                    >
                      {card.level}
                    </span>
                    <div>
                      <h3 className="text-xl font-semibold text-navy">{card.title}</h3>
                      <p className="mt-0.5 text-sm text-muted">{card.tagline}</p>
                    </div>
                  </div>
                  <div className="mt-[22px] flex flex-col border-t border-border">
                    {streams.map((stream) => {
                      const price = streamPrice(ofClass.filter(stream.match));
                      return (
                        <Link
                          key={stream.name}
                          href={`/courses?class=${card.level}`}
                          className="group flex items-center justify-between gap-3 border-b border-line py-3.5"
                        >
                          <span>
                            <span className="block text-[15px] font-semibold text-navy group-hover:text-primary">
                              {stream.name}
                            </span>
                            <span className="text-[13px] text-muted">
                              {stream.subjects}
                            </span>
                          </span>
                          <span className="whitespace-nowrap text-sm font-semibold text-primary">
                            {price} →
                          </span>
                        </Link>
                      );
                    })}
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </section>

      <section className="bg-white">
        <div className="mx-auto max-w-[1200px] px-4 py-[72px] sm:px-6">
          <div className="flex flex-wrap items-center justify-between gap-6 rounded-2xl bg-primary p-8 sm:p-12">
            <div className="flex-[1_1_360px]">
              <p className="font-hindi text-[15px] text-[#dbe6ff]">
                आज शुरू करें — कल का आत्मविश्वास बनाएँ।
              </p>
              <h2 className="mt-2.5 text-[26px] font-bold tracking-[-0.02em] text-white sm:text-[32px]">
                Boards are closer than they look.
              </h2>
              <p className="mt-2.5 max-w-[520px] text-base text-[#dbe6ff]">
                Start your 90-day crash course today and finish the syllabus
                with time left to revise.
              </p>
            </div>
            <Link
              href="/login"
              className="flex h-12 shrink-0 items-center whitespace-nowrap rounded-lg bg-white px-6 text-[15px] font-semibold text-primary hover:bg-primary-soft"
            >
              Create free account
            </Link>
          </div>
        </div>
      </section>
    </>
  );
}
