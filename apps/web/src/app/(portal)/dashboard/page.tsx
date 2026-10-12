import Link from "next/link";
import { PlayIcon, TestIcon } from "@/components/icons";
import { PortalTopbar } from "@/components/portal/PortalTopbar";
import { Card, LiveNowBadge, ProgressBar, SectionTitle } from "@/components/portal/ui";
import {
  currentChapter,
  dashboardSchedule,
  enrolledCourses,
  liveNow,
} from "@/lib/portal/data";
import { getStudent } from "@/lib/portal/student";

export const metadata = { title: "Dashboard" };

function greeting() {
  const hour = Number(
    new Intl.DateTimeFormat("en-IN", { hour: "numeric", hour12: false, timeZone: "Asia/Kolkata" }).format(
      new Date(),
    ),
  );
  if (hour < 12) return "Good morning";
  if (hour < 17) return "Good afternoon";
  return "Good evening";
}

export default async function DashboardPage() {
  const student = await getStudent();
  const resume = currentChapter.lessons?.find((l) => l.kind === "current");
  const crumb = [student.summary, student.medium ? `${student.medium} medium` : null]
    .filter(Boolean)
    .join(" · ");

  return (
    <>
      <PortalTopbar title={`${greeting()}, ${student.firstName}`} crumb={crumb} />
      <div className="flex max-w-[1280px] flex-wrap items-start gap-6 px-4 pb-12 pt-7 sm:px-8">
        <div className="flex min-w-0 flex-[1_1_520px] flex-col gap-6">
          <section className="flex flex-wrap items-end justify-between gap-5 rounded-xl bg-navy p-7 text-white">
            <div className="min-w-0 flex-[1_1_280px]">
              <div className="flex flex-wrap items-center gap-x-3 gap-y-2">
                <LiveNowBadge />
                <span className="whitespace-nowrap text-[13px] text-[#9aa7c2]">
                  {liveNow.time} · {liveNow.students} students
                </span>
              </div>
              <p className="mt-5 whitespace-nowrap text-[13px] font-semibold uppercase tracking-[0.04em] text-[#9fb8ff]">
                {liveNow.subject} · Chapter 0{currentChapter.number}
              </p>
              <h2 className="mt-1.5 text-[26px] font-bold tracking-[-0.02em] sm:text-[30px]">
                {currentChapter.title}
              </h2>
              <div className="mt-4 flex items-center gap-2.5">
                <span className="flex size-8 items-center justify-center rounded-full bg-[#2a3a6e] text-xs font-semibold text-[#c7d4ff]">
                  {liveNow.initials}
                </span>
                <span className="text-sm text-[#c8d1e4]">{liveNow.teacher}</span>
              </div>
            </div>
            <Link
              href="/live/classroom"
              className="flex h-[46px] shrink-0 items-center gap-2 whitespace-nowrap rounded-lg bg-white px-5 text-[15px] font-semibold text-navy hover:bg-primary-soft"
            >
              Join Live Class →
            </Link>
          </section>

          {resume ? (
            <section>
              <SectionTitle>Continue learning</SectionTitle>
              <Link
                href={`/lecture/${resume.id}`}
                className="flex gap-4 rounded-xl border border-border bg-white p-4 hover:border-primary-line"
              >
                <div className="relative flex h-[90px] w-[clamp(96px,30%,140px)] shrink-0 items-center justify-center rounded-lg bg-primary-soft">
                  <span className="flex size-9 items-center justify-center rounded-full bg-white text-primary shadow-[0_2px_8px_rgba(20,22,28,0.12)]">
                    <PlayIcon />
                  </span>
                  <span className="absolute bottom-2 right-2 rounded bg-navy/75 px-1.5 py-0.5 text-[11px] font-semibold text-white">
                    38:14
                  </span>
                </div>
                <div className="flex min-w-0 flex-1 flex-col justify-between gap-3">
                  <div>
                    <p className="text-xs font-semibold uppercase tracking-[0.06em] text-primary">
                      {currentChapter.subject}
                    </p>
                    <p className="mt-1 text-base font-semibold text-navy">
                      Chapter {currentChapter.number} · {currentChapter.title}
                    </p>
                  </div>
                  <div>
                    <div className="flex justify-between text-[13px]">
                      <span className="text-muted">68% complete</span>
                      <span className="font-semibold text-primary">Continue →</span>
                    </div>
                    <ProgressBar value={68} className="mt-2 h-1.5" />
                  </div>
                </div>
              </Link>
            </section>
          ) : null}

          <section>
            <div className="mb-3 flex items-center justify-between">
              <SectionTitle className="mb-0">My courses</SectionTitle>
              <Link href="/my-courses" className="text-sm font-semibold text-primary">
                See all
              </Link>
            </div>
            <div className="grid gap-4 [grid-template-columns:repeat(auto-fit,minmax(240px,1fr))]">
              {enrolledCourses.map((course) => (
                <Link
                  key={course.id}
                  href={`/my-courses?course=${course.id}`}
                  className="block rounded-xl border border-border bg-white p-5 hover:border-primary-line"
                >
                  <div className="flex justify-between gap-3">
                    <div>
                      <p className="text-[11px] font-semibold tracking-[0.06em] text-muted">
                        {course.batch}
                      </p>
                      <p className="mt-1.5 text-base font-semibold text-navy">{course.title}</p>
                      <p className="mt-1 text-[13px] text-muted">{course.next}</p>
                    </div>
                    <span className="text-xl font-bold text-primary">{course.pct}%</span>
                  </div>
                  <ProgressBar value={course.pct} className="mt-4 h-1.5" />
                  <p className="mt-2.5 text-xs text-muted">
                    {course.chaptersDone} of {course.chaptersTotal} chapters
                  </p>
                </Link>
              ))}
            </div>
          </section>

          <section className="flex flex-wrap gap-4 rounded-xl border border-[#f6e3c4] bg-[#fff8ec] px-5 py-[18px]">
            <span className="flex size-10 shrink-0 items-center justify-center rounded-[10px] bg-[#ffecd6] text-amber">
              <TestIcon size={20} />
            </span>
            <div className="min-w-0 flex-1">
              <p className="text-[15px] font-semibold text-navy">Physics test on Sunday</p>
              <p className="mt-[3px] text-sm text-[#8a6a3e]">20 questions · Chapters 1–3</p>
            </div>
            <Link href="/calendar" className="self-center text-sm font-semibold text-amber">
              View Details →
            </Link>
          </section>
        </div>

        <div className="flex max-w-full flex-[1_1_280px] flex-col gap-6">
          <Card className="p-5">
            <div className="flex items-center justify-between">
              <SectionTitle className="mb-0">Today&apos;s schedule</SectionTitle>
              <Link href="/calendar" className="text-[13px] font-semibold text-primary">
                Calendar →
              </Link>
            </div>
            <div className="mt-[18px] flex flex-col">
              {dashboardSchedule.map((slot) => (
                <div key={slot.time} className="flex gap-3.5">
                  <div
                    className={`w-[58px] shrink-0 text-[13px] font-semibold ${slot.live ? "text-navy" : "text-muted"}`}
                  >
                    {slot.time}
                  </div>
                  <div className="flex-1 border-l-2 border-track pb-[18px] pl-3.5">
                    <div className="flex items-center gap-2">
                      <span className="text-sm font-semibold text-navy">{slot.title}</span>
                      {slot.live ? (
                        <span className="rounded bg-danger-soft px-1.5 py-px text-[10px] font-bold text-danger">
                          LIVE
                        </span>
                      ) : null}
                    </div>
                    <p className="mt-[3px] text-[13px] text-muted">{slot.sub}</p>
                  </div>
                </div>
              ))}
            </div>
          </Card>

          <Card className="p-5">
            <SectionTitle className="mb-0">This week</SectionTitle>
            <div className="mt-4 grid grid-cols-2 gap-3">
              {[
                ["12/28", "Chapters done"],
                ["17/20", "Last test score"],
              ].map(([value, label]) => (
                <div key={label} className="rounded-lg bg-surface-soft p-3.5">
                  <p className="text-[22px] font-bold text-navy">{value}</p>
                  <p className="mt-0.5 text-xs text-muted">{label}</p>
                </div>
              ))}
            </div>
          </Card>

          <Card className="p-5">
            <div className="flex items-center justify-between">
              <SectionTitle className="mb-0">Latest updates</SectionTitle>
              <Link href="/notifications" className="text-[13px] font-semibold text-primary">
                All
              </Link>
            </div>
            <div className="mt-3 flex flex-col">
              <Link href="/materials" className="border-b border-line py-3">
                <p className="text-sm font-semibold text-navy">New notes uploaded</p>
                <p className="mt-0.5 text-[13px] text-muted">
                  Chapter 02 notes — Electrochemistry.
                </p>
              </Link>
              <Link href="/live" className="py-3">
                <p className="text-sm font-semibold text-navy">New recording available</p>
                <p className="mt-0.5 text-[13px] text-muted">
                  Yesterday&apos;s Chemistry class recording is now available.
                </p>
              </Link>
            </div>
          </Card>
        </div>
      </div>
    </>
  );
}

