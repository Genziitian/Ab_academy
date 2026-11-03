import Image from "next/image";
import Link from "next/link";
import { Countdown, DaysLeft } from "@/components/landing/Countdown";
import { PlayBadge } from "@/components/landing/PlayBadge";
import { SyllabusExplorer } from "@/components/landing/SyllabusExplorer";
import { listCourses } from "@/lib/catalog";
import { type Course, formatInr } from "@/lib/courses";
import {
  APP_SCREENSHOT,
  BATCH_START_LABEL,
  EXAM_DATE,
  FAQS,
  FEATURES,
  FOUNDERS,
  QUOTES,
  RESULTS,
  SYLLABUS,
  TEACHER,
  TOTAL_CHAPTERS,
  subjectKey,
} from "@/lib/landing";

const pad = (n: number) => String(n).padStart(2, "0");
const ORDER = ["Physics", "Chemistry", "Maths"];

/** The Class 12 single-subject PCM courses; any Class 12 course until those exist. */
function crashCourses(all: Course[]) {
  const paid = all.filter((c) => c.price > 0 && c.classLevel === 12);
  const pcm = paid
    .filter((c) => c.subjects.length === 1 && subjectKey(c.subjects[0]))
    .sort((a, b) => ORDER.indexOf(subjectKey(a.subjects[0])!) - ORDER.indexOf(subjectKey(b.subjects[0])!));
  return (pcm.length ? pcm : paid).map((c) => {
    const key = c.subjects.length === 1 ? subjectKey(c.subjects[0]) : null;
    return {
      slug: c.slug,
      name: key ?? c.stream ?? c.title,
      chapters: key ? SYLLABUS[key].length : c.chapters,
      price: c.price,
    };
  });
}

function Initials({ name, className = "" }: { name: string; className?: string }) {
  const letters = name
    .replace(/\b(Sir|Ma'am)\b/g, "")
    .trim()
    .split(/\s+/)
    .map((w) => w[0])
    .join("")
    .slice(0, 2);
  return (
    <div
      className={`flex items-center justify-center bg-[repeating-linear-gradient(135deg,#ece4d6_0_10px,#f3ede3_10px_20px)] font-serif text-coal ${className}`}
      aria-hidden
    >
      {letters}
    </div>
  );
}

export default async function HomePage() {
  const all = await listCourses();
  const courses = crashCourses(all);
  const demo = all.find((c) => c.price === 0);
  const from = courses.length ? formatInr(Math.min(...courses.map((c) => c.price))) : null;
  const exam = EXAM_DATE.toISOString();

  const joinBtn =
    "flex h-[58px] items-center justify-center whitespace-nowrap rounded-full bg-saffron px-8 text-[17px] font-bold text-coal hover:bg-coal hover:text-cream";

  return (
    <div className="overflow-x-clip">
      {/* Hero */}
      <section className="mx-auto grid max-w-[1280px] items-center gap-10 px-4 pb-14 pt-10 sm:px-6 lg:grid-cols-[1.1fr_1fr] lg:gap-14 lg:px-16 lg:py-[72px]">
        <div>
          <p className="text-xs font-bold uppercase tracking-[0.16em] text-clay sm:text-[13px]">
            Bihar Board · Class 12 Crash Course
          </p>
          <h1 className="mt-5 font-serif text-[56px] leading-[0.94] tracking-[-0.02em] text-balance sm:text-[84px] xl:text-[112px]">
            The <em className="text-saffron">last 90 days</em> before your boards.
          </h1>
          <p className="mt-6 max-w-[540px] text-lg leading-[1.55] text-pretty text-taupe sm:text-xl">
            Classes start {BATCH_START_LABEL}. Recorded classes you can watch anytime, live doubt sessions with{" "}
            {TEACHER.name}, chapter notes and board-pattern tests. Physics, Chemistry and Maths
            {from ? `, from ${from} per subject` : ""}. Taught in Hindi or Hinglish — you choose.
          </p>
          <div className="mt-9 flex flex-col gap-3 sm:flex-row sm:items-center sm:gap-5">
            <Link href="#courses" className={joinBtn}>
              Join Class 12 Crash Course
            </Link>
            <PlayBadge />
            {demo ? (
              <Link href={`/course/${demo.slug}`} className="text-center text-[15px] font-semibold text-coal underline decoration-saffron decoration-2 underline-offset-4 hover:text-clay">
                Watch the free demo
              </Link>
            ) : null}
          </div>
        </div>
        <div className="relative h-[420px] overflow-hidden rounded-3xl bg-[radial-gradient(120%_90%_at_50%_100%,#f2a86b_0%,#e8742a_38%,#b4521a_100%)] sm:h-[500px] lg:h-[580px]">
          {/* Soft rings behind the teacher. */}
          <div aria-hidden className="absolute left-1/2 top-[18%] size-[120%] -translate-x-1/2 rounded-full border border-white/15" />
          <div aria-hidden className="absolute left-1/2 top-[30%] size-[86%] -translate-x-1/2 rounded-full border border-white/20" />
          <p className="absolute left-6 top-6 z-10 font-serif text-[40px] leading-none text-cream sm:left-8 sm:top-8 sm:text-[52px]">
            {TEACHER.name}
            <span className="mt-2 block font-sans text-xs font-bold uppercase tracking-[0.16em] text-cream/85">
              Founder · {TEACHER.subjects}
            </span>
          </p>
          <Image
            src="/images/ajit-sir-cutout.png"
            alt={`${TEACHER.name}, founder and teacher at AB Academy`}
            fill
            priority
            sizes="(min-width: 1024px) 560px, 100vw"
            className="object-contain object-bottom pt-24"
          />
          <div className="absolute inset-x-4 bottom-4 flex flex-wrap items-center gap-3 rounded-2xl bg-cream px-5 py-4 sm:inset-x-6 sm:bottom-6 sm:gap-3.5">
            <span className="whitespace-nowrap rounded-full bg-[#c8321e] px-2.5 py-1 text-xs font-bold tracking-[0.06em] text-white">
              ● LIVE DOUBT SESSION
            </span>
            <div>
              <p className="text-base font-bold">Stuck on a chapter? Ask it live.</p>
              <p className="mt-0.5 text-sm text-taupe">
                {TEACHER.name} · from {BATCH_START_LABEL.replace("November", "Nov")}
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Countdown */}
      <section className="bg-coal text-cream">
        <div className="mx-auto grid max-w-[1280px] items-center gap-8 px-4 py-8 sm:px-6 lg:grid-cols-[1fr_auto_1fr] lg:gap-12 lg:px-16">
          <div>
            <p className="text-xs font-bold uppercase tracking-[0.16em] text-saffron sm:text-[13px]">Board exams begin in</p>
            <p className="mt-2 text-base leading-[1.5] text-mist">
              Bihar Board Class 12, expected in the first week of February 2027.
            </p>
          </div>
          <Countdown target={exam} />
          <div className="lg:flex lg:justify-end">
            <Link
              href="#courses"
              className="flex h-[52px] w-full items-center justify-center rounded-full bg-saffron px-7 text-base font-bold text-coal hover:bg-cream sm:w-fit"
            >
              Join before {BATCH_START_LABEL.replace("November", "Nov")}
            </Link>
          </div>
        </div>
      </section>

      {/* 01 How it works */}
      <section id="how" className="mx-auto max-w-[1280px] scroll-mt-24 px-4 py-20 sm:px-6 lg:px-16 lg:pb-28 lg:pt-32">
        <div className="grid items-end gap-6 lg:grid-cols-2 lg:gap-14">
          <div>
            <p className="kicker text-clay">01. How it works</p>
            <h2 className="mt-3 font-serif text-[48px] leading-[0.98] tracking-[-0.02em] text-balance sm:text-[64px] lg:text-[84px]">
              Watch anytime. Ask live.
            </h2>
          </div>
          <p className="max-w-[520px] text-lg leading-[1.6] text-pretty text-taupe sm:text-[19px]">
            Every chapter is a recorded class you can pause, rewind and rewatch. When you’re stuck, bring the
            question to a live doubt session and get it solved on the spot.
          </p>
        </div>
        <div className="mt-12 grid border-t-2 border-coal sm:grid-cols-2 lg:mt-14 lg:grid-cols-4">
          {FEATURES.map(([title, text], i) => (
            <div key={title} className="border-b border-sand py-7 pr-7 lg:border-b-0">
              <p className="text-[13px] font-bold uppercase tracking-[0.14em] text-clay">{pad(i + 1)}</p>
              <h3 className="mt-2.5 font-serif text-[34px] leading-[1.05] sm:text-[40px]">{title}</h3>
              <p className="mt-2.5 text-base leading-[1.6] text-taupe">{text}</p>
            </div>
          ))}
        </div>
        <div className="mt-14 lg:mt-[72px]">
          <SyllabusExplorer />
        </div>
      </section>

      {/* 02 Courses */}
      <section id="courses" className="scroll-mt-20 bg-coal text-cream">
        <div className="mx-auto max-w-[1280px] px-4 py-20 sm:px-6 lg:px-16 lg:py-28">
          <div className="grid items-end gap-6 lg:grid-cols-[1.3fr_1fr] lg:gap-14">
            <div>
              <p className="kicker text-saffron">02. Courses</p>
              <h2 className="mt-3 font-serif text-[48px] leading-[0.98] tracking-[-0.02em] text-balance sm:text-[64px] lg:text-[84px]">
                One subject. One crash course.
              </h2>
            </div>
            <p className="text-lg leading-[1.6] text-mist">
              Take only what you need. Every subject is its own Class 12 crash course
              {from ? `, starting at ${from}` : ""}.
            </p>
          </div>
          <div className="mt-12 grid gap-5 md:grid-cols-2 lg:mt-14 lg:grid-cols-3">
            {courses.map((c) => (
              <article
                key={c.slug}
                className="flex min-h-[380px] flex-col rounded-[22px] border border-coal-line p-7 transition-colors hover:border-saffron hover:bg-coal-soft sm:p-8"
              >
                <p className="text-[13px] font-bold uppercase tracking-[0.14em] text-dust">
                  Class 12{c.chapters ? ` · ${c.chapters} chapters` : ""}
                </p>
                <h3 className="mt-3.5 font-serif text-[52px] leading-none sm:text-[64px]">{c.name}</h3>
                <ul className="mt-6 flex flex-col gap-2.5 text-base text-mist">
                  <li>+ Recorded class for every chapter</li>
                  <li>+ Live doubt sessions with {TEACHER.name}</li>
                  <li>+ Chapter notes PDF</li>
                  <li>+ Board-pattern questions</li>
                </ul>
                <div className="mt-auto flex items-end justify-between gap-4 border-t border-coal-line pt-7">
                  <div>
                    <p className="text-[13px] font-bold uppercase tracking-[0.12em] text-dust">Starting at</p>
                    <p className="mt-1 font-serif text-[48px] leading-none text-saffron sm:text-[56px]">
                      {formatInr(c.price)}
                    </p>
                  </div>
                  <Link
                    href={`/course/${c.slug}`}
                    className="flex h-12 shrink-0 items-center rounded-full bg-saffron px-6 text-[15px] font-bold text-coal hover:bg-cream"
                  >
                    Enroll now
                  </Link>
                </div>
              </article>
            ))}
          </div>
        </div>
      </section>

      {/* 03 Teacher */}
      <section className="mx-auto grid max-w-[1280px] gap-10 px-4 py-20 sm:px-6 lg:grid-cols-[440px_1fr] lg:gap-16 lg:px-16 lg:py-28">
        {TEACHER.photo ? (
          <div className="relative h-[420px] overflow-hidden rounded-3xl lg:h-[560px]">
            <Image src={TEACHER.photo} alt={TEACHER.name} fill sizes="440px" className="object-cover" />
          </div>
        ) : (
          <Initials name={TEACHER.name} className="h-[360px] rounded-3xl text-[140px] lg:h-[560px]" />
        )}
        <div className="flex flex-col">
          <p className="kicker text-clay">03. Your teacher</p>
          <h2 className="mt-3 font-serif text-[80px] leading-[0.9] tracking-[-0.02em] sm:text-[104px] lg:text-[128px]">
            {TEACHER.name}
          </h2>
          <p className="mt-4 text-[15px] font-bold uppercase tracking-[0.14em] text-clay">{TEACHER.subjects}</p>
          <p className="mt-6 max-w-[560px] text-lg leading-[1.6] text-pretty text-taupe sm:text-[19px]">{TEACHER.bio}</p>
          <div className="mt-10 grid grid-cols-3 border-t-2 border-coal lg:mt-auto">
            {[
              [String(TEACHER.years), "years of teaching experience", true],
              ["3", "subjects, one teacher", false],
              [String(TOTAL_CHAPTERS), "Class 12 chapters covered", false],
            ].map(([n, label, accent], i) => (
              <div key={label as string} className={`pt-6 ${i ? "border-l border-sand pl-4 sm:pl-6" : "pr-4 sm:pr-6"}`}>
                <p className={`font-serif text-[48px] leading-none sm:text-[72px] ${accent ? "text-saffron" : ""}`}>{n}</p>
                <p className="mt-1.5 text-sm text-taupe sm:text-[15px]">{label}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* 04 Results — shown only with real entries */}
      {RESULTS.length ? (
        <section id="results" className="bg-saffron text-coal">
          <div className="mx-auto max-w-[1280px] px-4 py-20 sm:px-6 lg:px-16 lg:py-28">
            <p className="kicker">04. Results</p>
            <h2 className="mt-3 font-serif text-[56px] leading-[0.95] tracking-[-0.02em] sm:text-[96px]">The result wall.</h2>
            <div className="mt-12 grid grid-cols-2 gap-3 lg:grid-cols-4">
              {RESULTS.map((r) => (
                <div key={r.name + r.score} className="rounded-[18px] bg-cream p-6">
                  <p className="font-serif text-[48px] leading-none sm:text-[64px]">{r.score}</p>
                  <p className="mt-3.5 text-base font-bold">{r.name}</p>
                  <p className="mt-0.5 text-sm opacity-75">{r.meta}</p>
                </div>
              ))}
            </div>
          </div>
        </section>
      ) : null}

      {/* 05 Students — shown only with real quotes */}
      {QUOTES.length ? (
        <section className="mx-auto max-w-[1280px] px-4 py-20 sm:px-6 lg:px-16 lg:py-28">
          <p className="kicker text-clay">05. Students</p>
          <h2 className="mt-3 font-serif text-[48px] leading-[0.98] tracking-[-0.02em] sm:text-[84px]">In their words.</h2>
          <div className="no-scrollbar mt-12 flex snap-x snap-mandatory gap-5 overflow-x-auto pb-2">
            {QUOTES.map((q) => (
              <figure
                key={q.name + q.text}
                className="m-0 flex min-h-[300px] w-[85%] shrink-0 snap-start flex-col rounded-3xl border border-sand bg-paper p-8 sm:w-[42%]"
              >
                <blockquote className="font-serif text-[28px] leading-[1.18] sm:text-[34px]">“{q.text}”</blockquote>
                <figcaption className="mt-auto pt-7 text-[15px]">
                  <strong className="block">{q.name}</strong>
                  <span className="opacity-70">{q.meta}</span>
                </figcaption>
              </figure>
            ))}
          </div>
        </section>
      ) : null}

      {/* The app */}
      <section id="app" className="mx-auto max-w-[1280px] scroll-mt-24 px-4 py-20 sm:px-6 lg:px-16 lg:py-28">
        <div className="grid items-center gap-12 rounded-[28px] bg-coal p-8 text-cream sm:p-12 lg:grid-cols-[1.2fr_1fr] lg:p-16">
          <div>
            <p className="kicker text-saffron">{RESULTS.length ? "06" : "04"}. The app</p>
            <h2 className="mt-3 font-serif text-[44px] leading-none tracking-[-0.02em] sm:text-[72px]">
              Your classroom fits in your pocket.
            </h2>
            <p className="mt-4 max-w-[480px] text-lg leading-[1.6] text-mist">
              Sign in with Google, watch recorded classes, join live doubt sessions and read notes, all on the same
              account as the website.
            </p>
            <div className="mt-8 flex flex-col gap-3 sm:flex-row">
              <PlayBadge tone="light" />
              <Link href="#courses" className="flex h-[58px] items-center justify-center rounded-full bg-saffron px-7 text-base font-bold text-coal hover:bg-cream">
                Join Class 12 Crash Course
              </Link>
            </div>
          </div>
          <div className="relative mx-auto aspect-[9/19] w-[250px] overflow-hidden rounded-[40px] border-[6px] border-coal-line bg-coal-soft sm:w-[280px]">
            <Image src={APP_SCREENSHOT} alt="The AB Academy app home screen" fill sizes="280px" className="object-cover object-top" />
          </div>
        </div>
      </section>

      {/* 08 About */}
      <section id="about" className="mx-auto max-w-[1280px] scroll-mt-24 px-4 pb-20 sm:px-6 lg:px-16 lg:pb-28">
        <div className="grid gap-10 border-t-2 border-coal pt-8 lg:grid-cols-[1fr_1.3fr] lg:gap-16">
          <div>
            <p className="kicker text-clay">{RESULTS.length ? "07" : "05"}. About us</p>
            <h2 className="mt-3 font-serif text-[48px] leading-none tracking-[-0.02em] sm:text-[72px]">Built in Bihar, for Bihar Board.</h2>
            <p className="mt-4 max-w-[460px] text-lg leading-[1.6] text-taupe">
              A teacher with {TEACHER.years} years in the classroom and a developer, building the crash course they wish
              students had: affordable, focused and in your language.
            </p>
          </div>
          <div className="grid grid-cols-2 gap-4 sm:gap-5">
            {FOUNDERS.map((f) => (
              <div key={f.name}>
                {f.photo ? (
                  <div className="relative aspect-square overflow-hidden rounded-[18px] bg-sand">
                    <Image src={f.photo} alt={f.name} fill sizes="(min-width: 1024px) 320px, 45vw" className="object-cover object-top" />
                  </div>
                ) : (
                  <Initials name={f.name} className="aspect-square rounded-[18px] text-[72px] sm:text-[96px]" />
                )}
                <p className="mt-4 font-serif text-[28px] leading-none sm:text-4xl">{f.name}</p>
                <p className="mt-1.5 text-xs font-bold uppercase tracking-[0.12em] text-clay sm:text-[13px]">{f.role}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* 09 FAQ */}
      <section id="faq" className="mx-auto grid max-w-[1280px] scroll-mt-24 gap-10 px-4 pb-20 sm:px-6 lg:grid-cols-[1fr_1.4fr] lg:gap-16 lg:px-16 lg:pb-28">
        <div>
          <p className="kicker text-clay">{RESULTS.length ? "08" : "06"}. Questions</p>
          <h2 className="mt-3 font-serif text-[48px] leading-none tracking-[-0.02em] sm:text-[72px]">Asked often.</h2>
        </div>
        <div className="border-t-2 border-coal">
          {FAQS.map(([q, a], i) => (
            <details key={q} open={i === 0} className="group border-b border-sand">
              <summary className="flex cursor-pointer list-none items-center justify-between gap-5 py-6 text-lg font-semibold sm:text-xl [&::-webkit-details-marker]:hidden">
                {q}
                <span className="font-serif text-[34px] leading-none text-clay group-open:hidden">+</span>
                <span className="hidden font-serif text-[34px] leading-none text-clay group-open:inline">−</span>
              </summary>
              <p className="pb-6 pr-6 text-[17px] leading-[1.6] text-taupe sm:pr-16">{a}</p>
            </details>
          ))}
        </div>
      </section>

      {/* Final CTA */}
      <section className="overflow-hidden bg-saffron text-coal">
        <div className="mx-auto max-w-[1280px] px-4 py-20 sm:px-6 lg:px-16 lg:py-28">
          <div className="grid items-end gap-10 lg:grid-cols-[1.15fr_1fr] lg:gap-16">
            <div>
              <p className="text-xs font-bold uppercase tracking-[0.16em] sm:text-[13px]">
                Classes start Monday, {BATCH_START_LABEL}
              </p>
              <h2 className="mt-4 font-serif text-[60px] leading-[0.92] tracking-[-0.02em] text-balance sm:text-[96px] xl:text-[120px]">
                Make the last <em>90 days</em> count.
              </h2>
              <div className="mt-9 flex items-end gap-7">
                <div>
                  <p className="font-serif text-[52px] leading-[0.9] tabular-nums sm:text-[64px]">
                    <DaysLeft target={exam} />
                  </p>
                  <p className="mt-3.5 text-xs font-bold uppercase tracking-[0.14em]">Days to boards</p>
                </div>
                {from ? (
                  <>
                    <div className="h-14 w-px bg-coal/30" />
                    <div>
                      <p className="font-serif text-[52px] leading-[0.9] sm:text-[64px]">{from}</p>
                      <p className="mt-3.5 text-xs font-bold uppercase tracking-[0.14em]">Per subject, from</p>
                    </div>
                  </>
                ) : null}
              </div>
            </div>
            <div className="rounded-[28px] bg-coal p-6 text-cream sm:p-8">
              <p className="text-[13px] font-bold uppercase tracking-[0.14em] text-dust">Choose your crash course</p>
              <div className="mt-3 flex flex-col">
                {courses.map((c) => (
                  <Link
                    key={c.slug}
                    href={`/course/${c.slug}`}
                    className="flex items-center justify-between gap-4 border-b border-coal-line py-[18px] text-cream hover:text-saffron"
                  >
                    <span className="font-serif text-[30px] leading-none sm:text-4xl">{c.name}</span>
                    <span className="shrink-0 text-base font-bold">from {formatInr(c.price)} →</span>
                  </Link>
                ))}
              </div>
              <div className="mt-6 flex flex-col gap-2.5 sm:flex-row">
                <Link href="#courses" className="flex h-[58px] flex-1 items-center justify-center rounded-full bg-saffron px-6 text-base font-bold text-coal hover:bg-cream">
                  Join Class 12 Crash Course
                </Link>
                <PlayBadge tone="light" />
              </div>
            </div>
          </div>

        </div>
      </section>
    </div>
  );
}
