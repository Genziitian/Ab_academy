import Image from "next/image";
import Link from "next/link";
import { notFound } from "next/navigation";
import { PlayIcon } from "@/components/icons";
import { PortalTopbar } from "@/components/portal/PortalTopbar";
import { BATCH_START_LABEL } from "@/lib/landing";
import { getCourseCurriculum } from "@/lib/portal/live";

export default async function CourseCurriculumPage({ params }: { params: Promise<{ courseId: string }> }) {
  const { courseId } = await params;
  const data = await getCourseCurriculum(courseId);
  if (!data) notFound();
  const { course, chapters } = data;
  const subjects = [...new Set(chapters.map((c) => c.subject))];

  return (
    <>
      <PortalTopbar crumb={<Link href="/my-courses" className="hover:underline">← My courses</Link>} title={course.title} />
      <div className="px-4 pb-16 pt-6 sm:px-8">
        <section className="flex flex-wrap items-center gap-5 rounded-[22px] border border-sand bg-cream p-5">
          <div className="relative size-20 shrink-0 overflow-hidden rounded-2xl bg-[linear-gradient(145deg,#e8742a,#b4521a)]">
            {course.art ? <Image src={course.art} alt="" fill sizes="80px" className="object-cover" /> : null}
          </div>
          <dl className="flex flex-wrap gap-x-10 gap-y-3">
            {[
              [course.chapters, "chapters"],
              [course.lectures, "lectures ready"],
            ].map(([v, l]) => (
              <div key={String(l)}>
                <dd className="font-serif text-[36px] leading-none text-coal">{v}</dd>
                <dt className="text-sm text-taupe">{l}</dt>
              </div>
            ))}
          </dl>
          {course.lectures === 0 ? (
            <p className="w-full rounded-xl bg-paper px-4 py-3 text-sm text-taupe sm:ml-auto sm:w-auto">
              Lectures appear here from {BATCH_START_LABEL} as they are uploaded.
            </p>
          ) : null}
        </section>

        {chapters.length === 0 ? (
          <p className="mt-8 text-taupe">The chapter list for this course is being prepared.</p>
        ) : (
          <div className="mt-8 flex flex-col gap-3">
            {chapters.map((chapter, i) => (
              <details
                key={chapter.id}
                open={i === 0}
                className="group overflow-hidden rounded-[20px] border border-sand bg-cream [&_summary::-webkit-details-marker]:hidden"
              >
                <summary className="flex cursor-pointer list-none items-center gap-4 px-5 py-4">
                  <span className="flex size-10 shrink-0 items-center justify-center rounded-xl bg-primary-soft font-semibold tabular-nums text-clay">
                    {String(i + 1).padStart(2, "0")}
                  </span>
                  <span className="min-w-0 flex-1">
                    <span className="block truncate font-semibold text-coal">{chapter.title}</span>
                    <span className="text-sm text-taupe">
                      {subjects.length > 1 ? `${chapter.subject} · ` : ""}
                      {chapter.lessons.length ? `${chapter.lessons.length} ready` : "Coming soon"}
                    </span>
                  </span>
                  <span className="text-xl text-taupe transition-transform group-open:rotate-45">+</span>
                </summary>
                {chapter.lessons.length ? (
                  <ul className="divide-y divide-sand border-t border-sand">
                    {chapter.lessons.map((l) => (
                      <li key={l.id}>
                        <Link href={`/lecture/${l.id}`} className="flex items-center gap-3 px-5 py-3.5 hover:bg-paper">
                          <span className="flex size-9 shrink-0 items-center justify-center rounded-full bg-coal text-cream">
                            <PlayIcon size={13} />
                          </span>
                          <span className="min-w-0 flex-1">
                            <span className="block truncate font-medium text-coal">{l.title}</span>
                            <span className="text-sm text-taupe">
                              {l.minutes ? `${l.minutes} min` : "Video"}
                              {l.notes ? " · notes" : ""}
                            </span>
                          </span>
                          <span className="text-sm font-bold text-clay">Watch →</span>
                        </Link>
                      </li>
                    ))}
                  </ul>
                ) : (
                  <p className="border-t border-sand px-5 py-4 text-sm text-taupe">
                    The lecture and practice session for this chapter are coming soon.
                  </p>
                )}
              </details>
            ))}
          </div>
        )}
      </div>
    </>
  );
}
