import Link from "next/link";
import { notFound } from "next/navigation";
import { PlayIcon } from "@/components/icons";
import { PortalTopbar } from "@/components/portal/PortalTopbar";
import { CONTACT } from "@/lib/landing";
import { getLessonForStudent } from "@/lib/portal/live";
import { getStudent } from "@/lib/portal/student";

export const metadata = { title: "Lecture" };

export default async function LecturePage({ params }: { params: Promise<{ lessonId: string }> }) {
  const { lessonId } = await params;
  const [lesson, student] = await Promise.all([getLessonForStudent(lessonId), getStudent()]);
  if (!lesson) notFound();
  const mark = [student.phone ?? student.email ?? student.name].filter(Boolean).join(" ");

  return (
    <>
      <PortalTopbar
        crumb={
          <Link href={`/my-courses/${lesson.course.id}`} className="hover:underline">
            ← {lesson.course.title}
          </Link>
        }
        title={lesson.title}
      />
      <div className="grid gap-6 px-4 pb-16 pt-6 sm:px-8 xl:grid-cols-[1fr_340px]">
        <div>
          <div className="relative aspect-video overflow-hidden rounded-[22px] bg-coal">
            {lesson.entitled && lesson.youtubeId ? (
              <>
                <iframe
                  src={`https://www.youtube-nocookie.com/embed/${encodeURIComponent(lesson.youtubeId)}?rel=0&modestbranding=1&playsinline=1`}
                  title={lesson.title}
                  allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture; fullscreen"
                  allowFullScreen
                  className="absolute inset-0 size-full"
                />
                {/* Watermark: discourages screen recording and sharing. */}
                <span className="pointer-events-none absolute right-4 top-4 select-none text-xs font-semibold text-white/35">
                  {mark}
                </span>
              </>
            ) : (
              <div className="absolute inset-0 flex flex-col items-center justify-center gap-3 p-6 text-center text-cream">
                <span className="flex size-14 items-center justify-center rounded-full bg-white/10">
                  <PlayIcon size={20} />
                </span>
                <p className="max-w-[420px] text-mist">
                  {!lesson.entitled
                    ? "This lecture is for students enrolled in the course."
                    : lesson.hasVideo
                      ? "This video plays in the AB Academy app."
                      : "The video for this lecture is being uploaded. Check back soon."}
                </p>
              </div>
            )}
          </div>
          <p className="mt-4 text-sm text-taupe">
            {lesson.subject} · {lesson.chapterTitle}
          </p>
          {lesson.notes.length ? (
            <div className="mt-5 rounded-[20px] border border-sand bg-cream p-5">
              <p className="text-xs font-bold uppercase tracking-[0.14em] text-clay">Notes for this lecture</p>
              <ul className="mt-3 flex flex-col gap-2">
                {lesson.notes.map((n) => (
                  <li key={n.id}>
                    <Link href={`/notes/${n.id}`} className="font-semibold text-coal hover:text-clay">
                      {n.title} →
                    </Link>
                  </li>
                ))}
              </ul>
            </div>
          ) : null}
          <p className="mt-5 text-sm text-taupe">
            Doubt about this lecture? <Link href="/support" className="font-semibold text-clay hover:underline">Raise a ticket</Link> or write to {CONTACT.email}.
          </p>
        </div>

        <aside className="h-fit rounded-[22px] border border-sand bg-cream">
          <p className="border-b border-sand px-5 py-4 text-xs font-bold uppercase tracking-[0.14em] text-clay">
            In this chapter
          </p>
          <ul className="divide-y divide-sand">
            {lesson.chapterLessons.map((l) => (
              <li key={l.id}>
                <Link
                  href={`/lecture/${l.id}`}
                  aria-current={l.id === lesson.id ? "page" : undefined}
                  className={`flex items-center gap-3 px-5 py-3.5 ${l.id === lesson.id ? "bg-primary-soft" : "hover:bg-paper"}`}
                >
                  <span className={`flex size-8 shrink-0 items-center justify-center rounded-full ${l.id === lesson.id ? "bg-clay text-white" : "bg-paper text-coal"}`}>
                    <PlayIcon size={12} />
                  </span>
                  <span className="min-w-0 flex-1 truncate text-sm font-medium text-coal">{l.title}</span>
                </Link>
              </li>
            ))}
          </ul>
        </aside>
      </div>
    </>
  );
}
