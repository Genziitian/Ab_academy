import Link from "next/link";
import { notFound } from "next/navigation";
import { PlayIcon } from "@/components/icons";
import { PdfBadge } from "@/components/PdfBadge";
import { PortalTopbar } from "@/components/portal/PortalTopbar";
import { Arrow } from "@/components/ui";
import { courseTitle, subjectName } from "@/lib/i18n/content";
import { getT } from "@/lib/i18n/server";
import { CONTACT } from "@/lib/landing";
import { getLessonForStudent } from "@/lib/portal/live";
import { getStudent } from "@/lib/portal/student";

export const metadata = { title: "Lecture" };

export default async function LecturePage({ params }: { params: Promise<{ lessonId: string }> }) {
  const { lessonId } = await params;
  const [lesson, student, { t, locale }] = await Promise.all([getLessonForStudent(lessonId), getStudent(), getT()]);
  if (!lesson) notFound();
  const p = t.portal;
  const mark = [student.phone ?? student.email ?? student.name].filter(Boolean).join(" ");

  return (
    <>
      <PortalTopbar
        crumb={
          <Link href={`/my-courses/${lesson.course.id}`} className="hover:text-ab-ink">
            ← {courseTitle({ title: lesson.course.title, subjects: [lesson.subject] }, locale)}
          </Link>
        }
        title={lesson.title}
        lead={`${subjectName(lesson.subject, locale)} · ${lesson.chapterTitle}`}
      />
      <div className="grid gap-6 px-4 pb-16 pt-5 sm:px-8 xl:grid-cols-[1fr_340px]">
        <div>
          <div className="relative aspect-video overflow-hidden rounded-2xl bg-ab-ink">
            {lesson.entitled && lesson.youtubeId ? (
              <>
                {/*
                  Link-sharing guard. The sandbox has no allow-popups, so the
                  player's title, Share and "Watch on YouTube" links cannot
                  open youtube.com; clipboard access is not granted, so its
                  "Copy link" does nothing. This slows sharing down — it
                  cannot make an unlisted video secret.
                */}
                <iframe
                  src={`https://www.youtube-nocookie.com/embed/${encodeURIComponent(lesson.youtubeId)}?rel=0&modestbranding=1&playsinline=1&iv_load_policy=3`}
                  title={lesson.title}
                  sandbox="allow-scripts allow-same-origin allow-presentation"
                  referrerPolicy="strict-origin-when-cross-origin"
                  allow="accelerometer; autoplay; encrypted-media; gyroscope; fullscreen"
                  allowFullScreen
                  className="absolute inset-0 size-full"
                />
                {/* Covers the title and Share row at the top of the player. */}
                <span aria-hidden className="absolute inset-x-0 top-0 h-[60px]" />
                {/* Watermark: discourages screen recording and sharing. */}
                <span className="ab-num pointer-events-none absolute right-4 top-4 select-none text-xs text-white/35">{mark}</span>
              </>
            ) : (
              <div className="absolute inset-0 flex flex-col items-center justify-center gap-3 p-6 text-center text-white">
                <span className="flex size-12 items-center justify-center rounded-full bg-white/10">
                  <PlayIcon size={18} />
                </span>
                <p className="max-w-[420px] text-white/70">{!lesson.entitled ? p.enrolledOnly : lesson.hasVideo ? p.playsInApp : p.uploading}</p>
              </div>
            )}
          </div>

          {lesson.notes.length ? (
            <div className="mt-5 rounded-2xl border border-ab-rule p-2">
              <p className="px-3 pb-1 pt-2 text-sm text-ab-ink-2">{p.lectureNotes}</p>
              <ul>
                {lesson.notes.map((n) => (
                  <li key={n.id}>
                    <Link href={`/notes/${n.id}`} className="flex items-center gap-3 rounded-[10px] px-3 py-2.5 hover:bg-ab-canvas">
                      <PdfBadge size={28} />
                      <span className="flex-1 text-[15px] font-medium text-ab-ink">{n.title}</span>
                      <Arrow className="text-ab-ink-3" />
                    </Link>
                  </li>
                ))}
              </ul>
            </div>
          ) : null}
          <p className="mt-5 text-sm text-ab-ink-2">
            {p.doubtPre}{" "}
            <Link href="/support" className="font-medium text-ab-ink underline decoration-ab-rule-strong underline-offset-4 hover:decoration-ab-ink">
              {p.raiseTicket}
            </Link>{" "}
            {p.orWrite(CONTACT.email)}
          </p>
        </div>

        <aside className="h-fit rounded-[20px] bg-ab-tray p-1.5">
          <p className="px-3 pb-2 pt-1.5 text-sm text-ab-ink-2">{p.inChapter}</p>
          <ul className="overflow-hidden rounded-[14px] border border-ab-rule bg-ab-panel">
            {lesson.chapterLessons.map((l, i) => {
              const on = l.id === lesson.id;
              return (
                <li key={l.id} className="border-b border-ab-rule last:border-b-0">
                  <Link
                    href={`/lecture/${l.id}`}
                    aria-current={on ? "page" : undefined}
                    className={`flex items-center gap-3 px-4 py-3 ${on ? "bg-ab-canvas" : "hover:bg-ab-canvas/60"}`}
                  >
                    <span className={`ab-num w-6 shrink-0 text-[13px] ${on ? "text-ab-accent-ink" : "text-ab-ink-3"}`}>{String(i + 1).padStart(2, "0")}</span>
                    <span className={`min-w-0 flex-1 truncate text-sm ${on ? "font-medium text-ab-ink" : "text-ab-ink-2"}`}>{l.title}</span>
                    {on ? <span className="size-1.5 rounded-full bg-ab-accent" /> : null}
                  </Link>
                </li>
              );
            })}
          </ul>
        </aside>
      </div>
    </>
  );
}
