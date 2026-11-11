import Image from "next/image";
import Link from "next/link";
import { notFound } from "next/navigation";
import { PlayIcon } from "@/components/icons";
import { PortalTopbar } from "@/components/portal/PortalTopbar";
import { Arrow } from "@/components/ui";
import { formatDate } from "@/lib/i18n/config";
import { courseTitle, subjectName } from "@/lib/i18n/content";
import { getT } from "@/lib/i18n/server";
import { BATCH_START } from "@/lib/landing";
import { getCourseCurriculum } from "@/lib/portal/live";

export default async function CourseCurriculumPage({ params }: { params: Promise<{ courseId: string }> }) {
  const { courseId } = await params;
  const [data, { t, locale }] = await Promise.all([getCourseCurriculum(courseId), getT()]);
  if (!data) notFound();
  const p = t.portal;
  const { course, chapters } = data;
  const subjects = [...new Set(chapters.map((c) => c.subject))];

  return (
    <>
      <PortalTopbar
        crumb={
          <Link href="/my-courses" className="hover:text-ab-ink">
            ← {p.myCourses}
          </Link>
        }
        title={courseTitle(course, locale)}
      />
      <div className="px-4 pb-16 pt-5 sm:px-8">
        <section className="flex flex-wrap items-center gap-5 rounded-[20px] bg-ab-tray p-1.5 pr-5">
          <div className="relative h-20 w-32 shrink-0 overflow-hidden rounded-[14px] bg-ab-panel">
            {course.art ? <Image src={course.art} alt="" fill sizes="128px" className="object-cover" /> : null}
          </div>
          <dl className="flex flex-wrap gap-x-10 gap-y-3">
            {[
              [course.chapters, p.chaptersLabel],
              [course.lectures, p.lecturesReadyLabel],
            ].map(([v, l]) => (
              <div key={String(l)}>
                <dd className="ab-fig text-[28px] font-medium leading-none text-ab-ink">{v}</dd>
                <dt className="mt-1 text-sm text-ab-ink-2">{l}</dt>
              </div>
            ))}
          </dl>
          {course.lectures === 0 ? (
            <p className="w-full rounded-[12px] bg-ab-panel px-4 py-3 text-sm text-ab-ink-2 sm:ml-auto sm:w-auto">
              {p.appearFrom(formatDate(BATCH_START, locale, { day: "numeric", month: "long" }))}
            </p>
          ) : null}
        </section>

        {chapters.length === 0 ? (
          <p className="mt-8 text-ab-ink-2">{p.preparing}</p>
        ) : (
          <div className="mt-6 overflow-hidden rounded-2xl border border-ab-rule">
            {chapters.map((chapter, i) => (
              <details key={chapter.id} open={i === 0} className="group border-b border-ab-rule last:border-b-0">
                <summary className="flex cursor-pointer list-none items-center gap-4 px-5 py-4 hover:bg-ab-canvas/60">
                  <span className="ab-num w-7 shrink-0 text-[13px] text-ab-ink-3">{String(i + 1).padStart(2, "0")}</span>
                  <span className="min-w-0 flex-1">
                    <span className="block truncate font-medium text-ab-ink">{chapter.title}</span>
                    <span className="text-sm text-ab-ink-3">
                      {subjects.length > 1 ? `${subjectName(chapter.subject, locale)} · ` : ""}
                      {chapter.lessons.length ? p.nReady(chapter.lessons.length) : t.common.comingSoon}
                    </span>
                  </span>
                  <span className="relative size-3.5 shrink-0 text-ab-ink-3" aria-hidden>
                    <span className="absolute inset-x-0 top-1/2 h-px -translate-y-1/2 bg-current" />
                    <span className="absolute inset-y-0 left-1/2 w-px -translate-x-1/2 bg-current transition-transform group-open:scale-y-0" />
                  </span>
                </summary>
                {chapter.lessons.length ? (
                  <ul className="flex flex-col gap-1 px-3 pb-3 sm:pl-14">
                    {chapter.lessons.map((l) => (
                      <li key={l.id}>
                        <Link href={`/lecture/${l.id}`} className="group/l flex items-center gap-3 rounded-[12px] bg-ab-canvas px-3 py-3 hover:bg-ab-tray">
                          <span className="flex size-8 shrink-0 items-center justify-center rounded-full bg-ab-ink text-white">
                            <PlayIcon size={12} />
                          </span>
                          <span className="min-w-0 flex-1">
                            <span className="block truncate text-[15px] font-medium text-ab-ink">{l.title}</span>
                            <span className="ab-num text-[13px] text-ab-ink-3">
                              {l.minutes ? p.minutes(l.minutes) : p.video}
                              {l.notes ? ` · ${p.withNotes}` : ""}
                            </span>
                          </span>
                          <span className="hidden items-center gap-1 text-sm font-medium text-ab-ink sm:flex">
                            {t.common.watch}
                            <Arrow size={12} />
                          </span>
                        </Link>
                      </li>
                    ))}
                  </ul>
                ) : (
                  <p className="px-5 pb-4 text-sm text-ab-ink-3 sm:pl-16">{p.chapterSoon}</p>
                )}
              </details>
            ))}
          </div>
        )}
      </div>
    </>
  );
}
