import Link from "next/link";
import { CourseCards, NoCourses } from "@/components/portal/CourseCards";
import { PortalTopbar } from "@/components/portal/PortalTopbar";
import { PlanRegister, daysUntil } from "@/components/plan/PlanRegister";
import { Arrow, Pill, Tray, btn } from "@/components/ui";
import { formatDate, formatDateTime, formatTime, istHour } from "@/lib/i18n/config";
import { getT } from "@/lib/i18n/server";
import { BATCH_START, CONTACT, EXAM_DATE, PLAY_STORE_URL, batchStarted } from "@/lib/landing";
import { requestNow } from "@/lib/now";
import { getMyCourses, getUpcomingClasses } from "@/lib/portal/live";
import { getStudent } from "@/lib/portal/student";

export const metadata = { title: "Home" };

const SEGMENTS = 30;

function TileLink({ href, children }: { href: string; children: React.ReactNode }) {
  return (
    <Link href={href} className="inline-flex items-center gap-1 text-sm font-medium text-ab-ink hover:underline">
      {children}
      <Arrow size={12} />
    </Link>
  );
}

export default async function DashboardPage() {
  const [{ t, locale }, student, courses, classes] = await Promise.all([getT(), getStudent(), getMyCourses(), getUpcomingClasses(6)]);
  const p = t.portal;
  const now = requestNow();
  const hour = istHour(now);
  const part = hour < 12 ? "morning" : hour < 17 ? "afternoon" : "evening";
  const lectures = courses.reduce((n, c) => n + c.lectures, 0);
  const next = classes[0];
  const later = classes.slice(1, 4);
  const toExam = daysUntil(EXAM_DATE, now);

  // How much of the run-up to the exam (from enrolment season to the exam) has passed.
  const span = EXAM_DATE.getTime() - BATCH_START.getTime();
  const elapsed = Math.min(1, Math.max(0, (now - BATCH_START.getTime()) / span));
  const filled = Math.round(elapsed * SEGMENTS);

  return (
    <>
      <PortalTopbar
        title={p.greeting(part, student.firstName)}
        lead={p.dashLead}
        actions={
          <>
            {PLAY_STORE_URL ? (
              <a href={PLAY_STORE_URL} target="_blank" rel="noopener noreferrer" className={`${btn.secondary} !h-10 !text-sm`}>
                {t.nav.getApp}
              </a>
            ) : null}
            <Link href="/courses" className={`${btn.secondary} !h-10 !text-sm`}>
              {p.explore}
            </Link>
          </>
        }
      />

      <div className="flex flex-col gap-6 px-4 pb-16 pt-5 sm:px-8">
        {/* Stat trays */}
        <section className="grid grid-cols-2 gap-2.5 sm:gap-3 xl:grid-cols-4">
          <Tray label={p.tileCourses}>
            <p className="flex items-baseline gap-2">
              <span className="ab-fig text-[40px] font-medium leading-none">{courses.length}</span>
              <span className="text-[15px] text-ab-ink-2">{p.enrolled}</span>
            </p>
            <div className="mt-auto flex items-center justify-between gap-3 pt-6 text-sm">
              <span className="max-sm:hidden text-ab-ink-3">{t.home.batch}</span>
              <TileLink href="/my-courses">{p.openLink}</TileLink>
            </div>
          </Tray>

          <Tray label={p.tileLectures}>
            <p className="flex items-baseline gap-2">
              <span className="ab-fig text-[40px] font-medium leading-none">{lectures}</span>
              <span className="text-[15px] text-ab-ink-2">{p.ready}</span>
            </p>
            <div className="mt-auto flex items-center justify-between gap-3 pt-6 text-sm">
              <span className="max-sm:hidden text-ab-ink-3">{p.acrossCourses}</span>
              <TileLink href="/my-courses">{p.browseLink}</TileLink>
            </div>
          </Tray>

          <Tray label={p.tileLive}>
            <p className="flex items-baseline gap-2">
              <span className="ab-fig text-[40px] font-medium leading-none">{classes.length}</span>
              <span className="text-[15px] text-ab-ink-2">{p.scheduled}</span>
            </p>
            <div className="mt-auto flex items-center justify-between gap-3 pt-6 text-sm">
              <span className="max-sm:hidden truncate text-ab-ink-3">{next ? p.nextAt(formatDateTime(next.startsAt, locale)) : p.noneScheduled}</span>
              <TileLink href="/live">{p.viewLink}</TileLink>
            </div>
          </Tray>

          <Tray label={p.tileExam} aside={t.plan.expected}>
            <p className="flex items-baseline gap-2">
              <span className="ab-fig text-[40px] font-medium leading-none">{toExam}</span>
              <span className="text-[15px] text-ab-ink-2">{p.days}</span>
            </p>
            <div className="mt-4 flex h-6 gap-[3px]" aria-hidden>
              {Array.from({ length: SEGMENTS }, (_, i) => (
                <span key={i} className={`flex-1 rounded-[2px] ${i < filled ? "bg-ab-ink" : "bg-ab-tray"}`} />
              ))}
            </div>
            <p className="mt-3 text-sm text-ab-ink-3 max-sm:hidden">{p.expectedExam(formatDate(EXAM_DATE, locale))}</p>
          </Tray>
        </section>

        {/* Plan + next live class */}
        <section className="grid gap-4 xl:grid-cols-[1.35fr_1fr]">
          <PlanRegister start={BATCH_START} exam={EXAM_DATE} now={now} t={t} locale={locale} title={t.plan.yourPlan} compact />

          <div className="flex flex-col rounded-[22px] border border-ab-rule bg-ab-panel p-5 sm:p-6">
            {next ? (
              <>
                <div className="flex items-center justify-between gap-3">
                  {next.status === "LIVE" ? <Pill tone="live">{p.liveNow}</Pill> : <Pill>{p.nextLive}</Pill>}
                  <span className="ab-num text-sm text-ab-ink-2">{formatTime(next.startsAt, locale)}</span>
                </div>
                <h2 className="ab-title mt-5 text-2xl">{next.title}</h2>
                <p className="mt-1.5 text-[15px] text-ab-ink-2">
                  {t.common.teacherName} · {next.course}
                </p>
                <p className="ab-num mt-1 text-sm text-ab-ink-3">{formatDateTime(next.startsAt, locale)}</p>
                <div className="min-h-6 flex-1" />
                {PLAY_STORE_URL ? (
                  <a href={PLAY_STORE_URL} target="_blank" rel="noopener noreferrer" className={`${btn.primary} !h-12 w-full`}>
                    {p.joinInApp}
                  </a>
                ) : (
                  <Link href="/live" className={`${btn.primary} !h-12 w-full`}>
                    {p.live}
                  </Link>
                )}
                {later.length ? (
                  <div className="mt-5 border-t border-ab-rule pt-4">
                    <div className="flex items-center justify-between text-sm">
                      <span className="text-ab-ink-2">{p.upNext}</span>
                      <TileLink href="/live">{t.common.viewAll}</TileLink>
                    </div>
                    <ul className="mt-2">
                      {later.map((c) => (
                        <li key={c.id} className="grid grid-cols-[96px_1fr] gap-3 py-2.5">
                          <span className="ab-num text-[13px] leading-[1.4] text-ab-ink-3">
                            {formatDate(c.startsAt, locale, { day: "numeric", month: "short" })}
                            <br />
                            {formatTime(c.startsAt, locale)}
                          </span>
                          <span className="text-[15px] font-medium text-ab-ink">{c.title}</span>
                        </li>
                      ))}
                    </ul>
                  </div>
                ) : null}
              </>
            ) : (
              <>
                <Pill className="w-fit">{p.nextLive}</Pill>
                <h2 className="ab-title mt-5 text-2xl">{p.noLiveTitle}</h2>
                <p className="mt-2 text-[15px] leading-[1.6] text-ab-ink-2">
                  {batchStarted() ? p.liveNote : `${p.liveStarts(formatDate(BATCH_START, locale, { day: "numeric", month: "long" }))} ${p.liveNote}`}
                </p>
                <div className="min-h-6 flex-1" />
                <Link href="/live" className={`${btn.secondary} !h-12 w-full`}>
                  {p.live}
                </Link>
              </>
            )}
          </div>
        </section>

        {/* Courses */}
        <section>
          <div className="mb-4 flex items-end justify-between gap-4">
            <h2 className="ab-title text-xl">{p.coursesTitle}</h2>
            {courses.length ? <TileLink href="/my-courses">{t.common.seeAll}</TileLink> : null}
          </div>
          {courses.length ? <CourseCards courses={courses.slice(0, 3)} t={t} locale={locale} /> : <NoCourses t={t} />}
        </section>

        {/* Help */}
        <Link
          href="/support"
          className="flex flex-wrap items-center justify-between gap-3 rounded-2xl bg-ab-tray px-5 py-4 transition-colors hover:bg-ab-rule"
        >
          <span>
            <span className="block text-[15px] font-medium text-ab-ink">{p.helpTitle}</span>
            <span className="text-sm text-ab-ink-2">{p.helpBody(CONTACT.email)}</span>
          </span>
          <Arrow className="text-ab-ink-2" />
        </Link>
      </div>
    </>
  );
}
