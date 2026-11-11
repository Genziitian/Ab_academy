import Image from "next/image";
import Link from "next/link";
import { PlayBadge } from "@/components/landing/PlayBadge";
import { ShareButton } from "@/components/landing/ShareButton";
import { SyllabusExplorer } from "@/components/landing/SyllabusExplorer";
import { PlanRegister, daysUntil } from "@/components/plan/PlanRegister";
import { Arrow, Check, Eyebrow, Panel, Pill, SectionHead, btn } from "@/components/ui";
import { listCourses } from "@/lib/catalog";
import { type Course, courseArt, formatInr } from "@/lib/courses";
import { formatDate } from "@/lib/i18n/config";
import { courseTitle, subjectName } from "@/lib/i18n/content";
import { getT } from "@/lib/i18n/server";
import { requestNow } from "@/lib/now";
import { APP_SCREENSHOT, BATCH_START, EXAM_DATE, FOUNDERS, QUOTES, RESULTS, SYLLABUS, TEACHER, TOTAL_CHAPTERS, subjectKey } from "@/lib/landing";

const pad = (n: number) => String(n).padStart(2, "0");
const ORDER = ["Physics", "Chemistry", "Maths"];

/** The Class 12 single-subject PCM courses; any paid Class 12 course until those exist. */
function crashCourses(all: Course[]) {
  const paid = all.filter((c) => c.price > 0 && c.classLevel === 12);
  const pcm = paid
    .filter((c) => c.subjects.length === 1 && subjectKey(c.subjects[0]))
    .sort((a, b) => ORDER.indexOf(subjectKey(a.subjects[0])!) - ORDER.indexOf(subjectKey(b.subjects[0])!));
  return (pcm.length ? pcm : paid).map((c) => {
    const key = c.subjects.length === 1 ? subjectKey(c.subjects[0]) : null;
    return {
      course: c,
      key,
      chapters: key ? SYLLABUS[key].length : (c.chapters ?? 0),
      originalPrice: c.originalPrice && c.originalPrice > c.price ? c.originalPrice : null,
    };
  });
}

function initialsOf(name: string) {
  return name
    .replace(/\b(Sir|Ma'am)\b/g, "")
    .trim()
    .split(/\s+/)
    .map((w) => w[0])
    .join("")
    .slice(0, 2);
}

export default async function HomePage() {
  const [{ t, locale }, all] = await Promise.all([getT(), listCourses()]);
  const h = t.home;
  const now = requestNow();
  const courses = crashCourses(all);
  const demo = all.find((c) => c.price === 0);
  const from = courses.length ? formatInr(Math.min(...courses.map((c) => c.course.price))) : null;
  const startLong = formatDate(BATCH_START, locale, { day: "numeric", month: "long" });
  const startShort = formatDate(BATCH_START, locale);
  const teacher = t.common.teacherName;
  const container = "mx-auto max-w-[1280px] px-4 sm:px-6 lg:px-10";

  return (
    <div className="overflow-x-clip">
      {/* Hero: one line of promise on the left, the 60-day plan on the right. */}
      <section className={`${container} grid items-center gap-12 pb-16 pt-12 sm:pt-16 lg:grid-cols-[1fr_1fr] lg:gap-16 lg:pb-24 lg:pt-24`}>
        <div>
          <Eyebrow>{h.eyebrow}</Eyebrow>
          <h1 className="ab-display mt-5 max-w-[560px] text-[44px] sm:text-[60px] xl:text-[72px]">{h.title}</h1>
          <p className="mt-5 max-w-[500px] text-[17px] leading-[1.65] text-ab-ink-2">{h.lead}</p>
          <div className="mt-8 flex flex-col gap-3 sm:flex-row sm:items-center">
            <Link href="#courses" className={`${btn.primary} ${btn.lg}`}>
              {h.ctaCourses}
              <Arrow />
            </Link>
            {demo ? (
              <Link href={`/course/${demo.slug}`} className={`${btn.ghost} ${btn.lg}`}>
                {h.ctaDemo}
              </Link>
            ) : null}
          </div>
          <ul className="mt-8 flex flex-wrap items-center gap-x-3 gap-y-1 text-sm text-ab-ink-3">
            {h.meta(startLong, from).map((item, i) => (
              <li key={item} className="flex items-center gap-3">
                {i ? <span className="size-1 rounded-full bg-ab-rule-strong" aria-hidden /> : null}
                {item}
              </li>
            ))}
          </ul>
        </div>
        <PlanRegister start={BATCH_START} exam={EXAM_DATE} now={now} t={t} locale={locale} variant="hero" />
      </section>

      {/* How it works */}
      <section id="how" className="scroll-mt-24 border-y border-ab-rule bg-ab-panel">
        <div className={`${container} grid gap-10 py-20 lg:grid-cols-[1fr_1.35fr] lg:gap-16 lg:py-28`}>
          <SectionHead eyebrow={`01 · ${h.howEyebrow}`} title={h.howTitle} lead={h.howLead} className="lg:sticky lg:top-28 lg:self-start" />
          <ol className="border-t border-ab-ink">
            {h.features.map(([title, text], i) => (
              <li key={title} className="grid grid-cols-[48px_1fr] gap-x-4 border-b border-ab-rule py-7 sm:grid-cols-[64px_1fr]">
                <span className="ab-num pt-1 text-sm text-ab-ink-3">{pad(i + 1)}</span>
                <div>
                  <h3 className="ab-title text-[22px] sm:text-2xl">{title}</h3>
                  <p className="mt-2 max-w-[520px] text-base leading-[1.6] text-ab-ink-2">{text}</p>
                </div>
              </li>
            ))}
          </ol>
        </div>
      </section>

      {/* Syllabus */}
      <section className={`${container} py-20 lg:py-28`}>
        <SectionHead eyebrow={`02 · ${h.syllabusEyebrow}`} title={h.syllabusTitle} lead={h.syllabusHint} />
        <div className="mt-10">
          <SyllabusExplorer />
        </div>
      </section>

      {/* Courses */}
      <section id="courses" className="scroll-mt-20 border-t border-ab-rule">
        <div className={`${container} py-20 lg:py-28`}>
          <div className="grid items-end gap-6 lg:grid-cols-[1.2fr_1fr]">
            <SectionHead eyebrow={`03 · ${h.coursesEyebrow}`} title={h.coursesTitle} />
            <p className="max-w-[460px] text-[17px] leading-[1.6] text-ab-ink-2 lg:justify-self-end">{h.coursesLead(from)}</p>
          </div>
          <div className="mt-12 grid gap-5 md:grid-cols-2 lg:grid-cols-3">
            {courses.map(({ course: c, key, chapters, originalPrice }) => {
              const name = key ? subjectName(key, locale) : courseTitle(c, locale);
              const art = courseArt(c);
              return (
                <Panel as="article" key={c.slug} className="group flex flex-col overflow-hidden transition-colors hover:border-ab-rule-strong">
                  <div className="relative aspect-[16/7] bg-ab-tray">
                    {art ? <Image src={art} alt="" fill sizes="(min-width: 1024px) 400px, 100vw" className="object-cover" /> : null}
                    <div className="absolute inset-x-4 top-4 flex items-start justify-between">
                      <Pill tone="ink" className="!h-6 !text-xs">{h.batch}</Pill>
                      <ShareButton path={`/course/${c.slug}`} title={courseTitle(c, locale)} />
                    </div>
                  </div>
                  <div className="flex flex-1 flex-col p-6">
                    <p className="text-[13px] text-ab-ink-3">
                      {t.common.classN(12)} · {t.common.board}
                    </p>
                    <h3 className="ab-title mt-1.5 text-2xl">{key ? t.common.crashCourse(name) : name}</h3>
                    <p className="mt-2.5 text-[15px] leading-[1.6] text-ab-ink-2">{h.cardBody(name)}</p>
                    <ul className="mt-5 flex flex-col gap-2 text-[15px] text-ab-ink">
                      {[chapters ? t.common.chapters(chapters) : null, h.lecturePractice, `${h.liveDoubts} · ${teacher}`]
                        .filter(Boolean)
                        .map((line) => (
                          <li key={line} className="flex items-center gap-2.5">
                            <Check className="text-ab-accent" />
                            {line}
                          </li>
                        ))}
                    </ul>
                    <div className="min-h-6 flex-1" />
                    <div className="flex items-end justify-between gap-4 border-t border-ab-rule pt-5">
                      <div className="text-[13px] leading-[1.5] text-ab-ink-3">
                        <p>{h.starts(startShort)}</p>
                        <p>{t.common.hindiOrHinglish}</p>
                      </div>
                      <div className="text-right">
                        {originalPrice ? <p className="ab-num text-sm text-ab-ink-3 line-through">{formatInr(originalPrice)}</p> : null}
                        <p className="ab-fig text-[32px] font-medium leading-none text-ab-ink">{formatInr(c.price)}</p>
                      </div>
                    </div>
                    <div className="mt-5 grid grid-cols-2 gap-2">
                      <Link href={`/course/${c.slug}`} className={btn.secondary}>
                        {t.common.details}
                      </Link>
                      <Link href={`/checkout/${c.slug}`} className={btn.primary}>
                        {t.common.enroll}
                      </Link>
                    </div>
                  </div>
                </Panel>
              );
            })}
          </div>

          {/* Everything included */}
          <div className="mt-6 grid gap-8 rounded-2xl border border-ab-rule bg-ab-panel p-6 sm:p-8 lg:grid-cols-[1fr_1.4fr] lg:items-center">
            <div>
              <h3 className="ab-title text-2xl sm:text-[28px]">{h.includedTitle}</h3>
              <p className="mt-2 text-[15px] leading-[1.6] text-ab-ink-2">{h.includedLead}</p>
            </div>
            <ul className="grid grid-cols-1 gap-x-6 gap-y-3 sm:grid-cols-2">
              {h.includedItems.map((item) => (
                <li key={item} className="flex items-center gap-2.5 border-b border-ab-rule pb-3 text-[15px] text-ab-ink">
                  <Check className="text-ab-accent" />
                  {item}
                </li>
              ))}
            </ul>
          </div>
        </div>
      </section>

      {/* Teacher */}
      <section className="border-y border-ab-rule bg-ab-panel">
        <div className={`${container} grid gap-10 py-20 lg:grid-cols-[420px_1fr] lg:gap-16 lg:py-28`}>
          {TEACHER.photo ? (
            <div className="relative aspect-[888/931] overflow-hidden rounded-2xl bg-ab-tray">
              <Image src={TEACHER.photo} alt={teacher} fill sizes="(min-width: 1024px) 420px, 100vw" className="object-cover" />
            </div>
          ) : (
            <div className="ab-fig flex aspect-square items-center justify-center rounded-2xl bg-ab-tray text-[120px] text-ab-ink-3">
              {initialsOf(TEACHER.name)}
            </div>
          )}
          <div className="flex flex-col">
            <Eyebrow>04 · {h.teacherEyebrow}</Eyebrow>
            <h2 className="ab-display mt-3 text-[52px] sm:text-[72px] lg:text-[88px]">{teacher}</h2>
            <p className="mt-3 text-[15px] font-medium text-ab-accent-ink">{h.teacherSubjects}</p>
            <p className="mt-6 max-w-[560px] text-lg leading-[1.65] text-ab-ink-2">{h.teacherBio}</p>
            <dl className="mt-10 grid grid-cols-3 border-t border-ab-ink lg:mt-auto">
              {[
                [String(TEACHER.years), h.teacherYears],
                ["3", h.teacherSubjectsLabel],
                [String(TOTAL_CHAPTERS), h.teacherChapters],
              ].map(([n, l], i) => (
                <div key={l} className={`pt-5 ${i ? "border-l border-ab-rule pl-4 sm:pl-6" : "pr-4"}`}>
                  <dd className="ab-fig text-[40px] font-medium leading-none sm:text-[56px]">{n}</dd>
                  <dt className="mt-2 text-sm text-ab-ink-3">{l}</dt>
                </div>
              ))}
            </dl>
          </div>
        </div>
      </section>

      {/* Results and reviews — shown only with real entries (lib/landing.ts). */}
      {RESULTS.length ? (
        <section className={`${container} py-20`}>
          <div className="grid grid-cols-2 gap-3 lg:grid-cols-4">
            {RESULTS.map((r) => (
              <Panel key={r.name + r.score} className="p-6">
                <p className="ab-fig text-5xl font-medium">{r.score}</p>
                <p className="mt-3 font-medium">{r.name}</p>
                <p className="text-sm text-ab-ink-3">{r.meta}</p>
              </Panel>
            ))}
          </div>
        </section>
      ) : null}
      {QUOTES.length ? (
        <section className={`${container} grid gap-4 py-20 md:grid-cols-2 lg:grid-cols-3`}>
          {QUOTES.map((q) => (
            <Panel as="article" key={q.name} className="flex flex-col p-6">
              <blockquote className="text-[17px] leading-[1.6] text-ab-ink">“{q.text}”</blockquote>
              <p className="mt-auto pt-5 text-sm text-ab-ink-3">
                <strong className="font-medium text-ab-ink">{q.name}</strong> · {q.meta}
              </p>
            </Panel>
          ))}
        </section>
      ) : null}

      {/* The app */}
      <section id="app" className={`${container} scroll-mt-24 py-20 lg:py-28`}>
        <div className="grid items-center gap-10 rounded-[24px] bg-ab-tray p-1.5 lg:grid-cols-[1.25fr_1fr]">
          <div className="p-6 sm:p-10 lg:p-12">
            <Eyebrow>05 · {h.appEyebrow}</Eyebrow>
            <h2 className="ab-display mt-3 text-[34px] sm:text-[44px]">{h.appTitle}</h2>
            <p className="mt-4 max-w-[480px] text-[17px] leading-[1.6] text-ab-ink-2">{h.appLead}</p>
            <div className="mt-8 flex flex-col gap-3 sm:flex-row">
              <PlayBadge />
              <Link href="#courses" className={`${btn.secondary} !h-12`}>
                {t.nav.join}
              </Link>
            </div>
          </div>
          <div className="flex justify-center rounded-[18px] border border-ab-rule bg-ab-panel px-6 pt-10">
            <div className="relative aspect-[540/1000] w-[240px] overflow-hidden rounded-t-[32px] border-x-[6px] border-t-[6px] border-ab-ink bg-ab-ink sm:w-[260px]">
              <Image src={APP_SCREENSHOT} alt={h.appAlt} fill sizes="260px" className="object-cover object-top" />
            </div>
          </div>
        </div>
      </section>

      {/* About */}
      <section id="about" className={`${container} scroll-mt-24 pb-20 lg:pb-28`}>
        <div className="grid gap-10 border-t border-ab-ink pt-10 lg:grid-cols-[1fr_1.2fr] lg:gap-16">
          <SectionHead eyebrow={`06 · ${h.aboutEyebrow}`} title={h.aboutTitle} lead={h.aboutLead(TEACHER.years)} />
          <div className="grid grid-cols-2 gap-4 sm:gap-5">
            {FOUNDERS.map((f) => {
              const name = f.name === "Ajit Sir" ? teacher : f.name;
              return (
                <div key={f.name}>
                  {f.photo ? (
                    <div className="relative aspect-square overflow-hidden rounded-2xl bg-ab-tray">
                      <Image src={f.photo} alt={name} fill sizes="(min-width: 1024px) 320px, 45vw" className="object-cover object-top" />
                    </div>
                  ) : (
                    <div className="ab-fig flex aspect-square items-center justify-center rounded-2xl border border-ab-rule bg-ab-panel text-[64px] text-ab-ink-3 sm:text-[88px]" aria-hidden>
                      {initialsOf(f.name)}
                    </div>
                  )}
                  <p className="ab-title mt-4 text-xl sm:text-2xl">{name}</p>
                  <p className="mt-1 text-sm text-ab-ink-3">{h.roles[f.role] ?? f.role}</p>
                </div>
              );
            })}
          </div>
        </div>
      </section>

      {/* FAQ */}
      <section id="faq" className="scroll-mt-24 border-t border-ab-rule bg-ab-panel">
        <div className={`${container} grid gap-10 py-20 lg:grid-cols-[1fr_1.4fr] lg:gap-16 lg:py-28`}>
          <SectionHead eyebrow={`07 · ${h.faqEyebrow}`} title={h.faqTitle} />
          <div className="border-t border-ab-ink">
            {h.faqs.map(([q, a], i) => (
              <details key={q} open={i === 0} className="group border-b border-ab-rule">
                <summary className="flex cursor-pointer list-none items-start justify-between gap-6 py-5 text-[17px] font-medium text-ab-ink sm:text-lg">
                  {q}
                  <span className="relative mt-1.5 size-4 shrink-0 text-ab-ink-3" aria-hidden>
                    <span className="absolute inset-x-0 top-1/2 h-px -translate-y-1/2 bg-current" />
                    <span className="absolute inset-y-0 left-1/2 w-px -translate-x-1/2 bg-current transition-transform group-open:scale-y-0" />
                  </span>
                </summary>
                <p className="max-w-[640px] pb-6 pr-10 text-base leading-[1.65] text-ab-ink-2">{a}</p>
              </details>
            ))}
          </div>
        </div>
      </section>

      {/* Final call to action */}
      <section className={`${container} py-16 lg:py-20`}>
        <div className="grid gap-10 rounded-[28px] bg-ab-ink p-7 text-white sm:p-10 lg:grid-cols-[1.15fr_1fr] lg:gap-16 lg:p-14">
          <div className="flex flex-col">
            <p className="ab-eyebrow !text-white/50">{h.finalEyebrow(startLong)}</p>
            <h2 className="ab-display mt-4 text-[40px] sm:text-[56px]">{h.finalTitle}</h2>
            <dl className="mt-10 flex gap-10 border-t border-white/15 pt-6 lg:mt-auto">
              <div>
                <dd className="ab-fig text-[44px] font-medium leading-none text-ab-accent">{daysUntil(EXAM_DATE, now)}</dd>
                <dt className="mt-2 text-sm text-white/60">{h.daysToBoards}</dt>
              </div>
              {from ? (
                <div>
                  <dd className="ab-fig text-[44px] font-medium leading-none">{from}</dd>
                  <dt className="mt-2 text-sm text-white/60">{h.perSubjectFrom}</dt>
                </div>
              ) : null}
            </dl>
          </div>
          <div className="rounded-[18px] border border-white/10 bg-white/[0.04] p-2">
            <p className="px-4 pb-1 pt-3 text-sm text-white/55">{h.choose}</p>
            {courses.map(({ course: c, key }) => (
              <Link
                key={c.slug}
                href={`/course/${c.slug}`}
                className="flex items-center justify-between gap-4 rounded-xl px-4 py-4 transition-colors hover:bg-white/[0.06]"
              >
                <span className="ab-title text-[22px] sm:text-2xl">{key ? subjectName(key, locale) : courseTitle(c, locale)}</span>
                <span className="ab-num flex shrink-0 items-center gap-2 text-[15px] text-white/75">
                  {h.from(formatInr(c.price))}
                  <Arrow />
                </span>
              </Link>
            ))}
            <Link href="#courses" className="mt-2 flex h-12 items-center justify-center gap-2 rounded-[10px] bg-white text-[15px] font-medium text-ab-ink hover:bg-ab-canvas">
              {t.nav.join}
              <Arrow />
            </Link>
          </div>
        </div>
      </section>
    </div>
  );
}
