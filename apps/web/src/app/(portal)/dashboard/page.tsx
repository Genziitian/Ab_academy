import Link from "next/link";
import { Countdown } from "@/components/landing/Countdown";
import { CourseCards, NoCourses } from "@/components/portal/CourseCards";
import { PortalTopbar } from "@/components/portal/PortalTopbar";
import { BATCH_START, BATCH_START_LABEL, CONTACT, TEACHER, batchStarted } from "@/lib/landing";
import { getMyCourses, getUpcomingClasses } from "@/lib/portal/live";
import { getStudent } from "@/lib/portal/student";

export const metadata = { title: "Home" };

function greeting() {
  const h = Number(new Date().toLocaleString("en-IN", { hour: "numeric", hour12: false, timeZone: "Asia/Kolkata" }));
  return h < 12 ? "Good morning" : h < 17 ? "Good afternoon" : "Good evening";
}

export default async function DashboardPage() {
  const [student, courses, classes] = await Promise.all([getStudent(), getMyCourses(), getUpcomingClasses(3)]);
  const started = batchStarted();
  const next = classes[0];

  return (
    <>
      <PortalTopbar crumb={greeting()} title={student.firstName} />
      <div className="flex flex-col gap-8 px-4 pb-16 pt-6 sm:px-8">
        {/* Batch start / next class */}
        <section className="grid gap-6 overflow-hidden rounded-[26px] bg-coal p-6 text-cream sm:p-8 lg:grid-cols-[1fr_auto] lg:items-center">
          {started ? (
            <div>
              <p className="text-xs font-bold uppercase tracking-[0.16em] text-saffron">
                {next ? "Next live class" : "Classes are on"}
              </p>
              <h2 className="mt-3 font-serif text-[36px] leading-none sm:text-[48px]">
                {next ? next.title : "Pick up where you left off."}
              </h2>
              <p className="mt-3 text-mist">
                {next
                  ? new Date(next.startsAt).toLocaleString("en-IN", { weekday: "long", hour: "numeric", minute: "2-digit", timeZone: "Asia/Kolkata" })
                  : `New lectures are added as ${TEACHER.name} uploads them.`}
              </p>
            </div>
          ) : (
            <>
              <div>
                <p className="text-xs font-bold uppercase tracking-[0.16em] text-saffron">Board 2027 batch</p>
                <h2 className="mt-3 font-serif text-[36px] leading-none sm:text-[52px]">Classes start {BATCH_START_LABEL}.</h2>
                <p className="mt-3 max-w-[460px] text-mist">
                  Recorded lectures, practice sessions and live doubt classes with {TEACHER.name} begin then.
                </p>
              </div>
              <Countdown target={BATCH_START.toISOString()} />
            </>
          )}
        </section>

        {/* Courses */}
        <section>
          <div className="mb-4 flex items-end justify-between gap-4">
            <h2 className="font-serif text-[32px] leading-none text-coal">My courses</h2>
            {courses.length ? (
              <Link href="/my-courses" className="text-sm font-bold text-clay hover:underline">
                See all
              </Link>
            ) : null}
          </div>
          {courses.length ? <CourseCards courses={courses} /> : <NoCourses />}
        </section>

        {/* Help */}
        <section className="grid gap-4 sm:grid-cols-2">
          <Link href="/live" className="rounded-[22px] border border-sand bg-cream p-6 hover:border-coal">
            <p className="text-xs font-bold uppercase tracking-[0.14em] text-clay">Live classes</p>
            <p className="mt-2 text-lg font-semibold text-coal">
              {next ? `${classes.length} coming up` : `Live doubt classes start ${BATCH_START_LABEL}`}
            </p>
          </Link>
          <Link href="/support" className="rounded-[22px] border border-sand bg-cream p-6 hover:border-coal">
            <p className="text-xs font-bold uppercase tracking-[0.14em] text-clay">Need help?</p>
            <p className="mt-2 text-lg font-semibold text-coal">Raise a ticket or write to {CONTACT.email}</p>
          </Link>
        </section>
      </div>
    </>
  );
}
