import Image from "next/image";
import Link from "next/link";
import { notFound } from "next/navigation";
import { IconArrowUp, IconChevronDown, IconExternal, IconFile, IconPencil, IconPlay, IconPlus } from "@/components/admin/AdminIcons";
import { ConfirmDelete, Modal, ModalActions, ModalForm } from "@/components/admin/Dialog";
import { Field } from "@/components/admin/Fields";
import { getCourse, getCourseTree } from "@/lib/admin/data";
import { formatRupees } from "@/lib/admin/format";
import { courseArt } from "@/lib/courses";
import { deleteCourseAction } from "../actions";
import { CourseForm } from "../CourseForm";
import {
  addChapterAction,
  deleteChapterAction,
  deleteLectureAction,
  deleteNotesAction,
  moveChapterAction,
  renameChapterAction,
} from "./actions";
import { LectureForm } from "./LectureForm";

export const metadata = { title: "Manage course" };

const ghost =
  "inline-flex h-9 items-center gap-1.5 rounded-full border border-sand bg-cream px-3.5 text-sm font-semibold text-coal hover:border-clay hover:text-clay";
const iconBtn = "flex size-9 items-center justify-center rounded-full text-taupe hover:bg-paper hover:text-coal";

function Chip({ tone, children }: { tone: "ok" | "warn" | "muted" | "accent"; children: React.ReactNode }) {
  const cls = {
    ok: "bg-[#e9f6ee] text-[#1d6b3d]",
    warn: "bg-[#fff1df] text-[#8a4b0f]",
    muted: "bg-paper text-taupe",
    accent: "bg-primary-soft text-clay",
  }[tone];
  return <span className={`whitespace-nowrap rounded-full px-2.5 py-0.5 text-xs font-semibold ${cls}`}>{children}</span>;
}

export default async function ManageCoursePage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const course = await getCourse(id);
  if (!course) notFound();
  const subjects = await getCourseTree(id);

  const chapters = subjects.flatMap((s) => s.chapters);
  const lessons = chapters.flatMap((c) => c.lessons);
  const withVideo = lessons.filter((l) => l.videoRef || l.storagePath).length;
  const art = course.thumbnailUrl ?? courseArt({ subjects: course.subjects, price: course.priceInr });
  const slug = course.slug;
  const defaultSubject = subjects[0]?.name ?? course.subjects[0] ?? "General";

  return (
    <>
      <Link href="/admin/courses" className="text-sm font-semibold text-clay hover:underline">
        ← All courses
      </Link>

      {/* Course header */}
      <section className="mt-4 grid gap-6 overflow-hidden rounded-[26px] bg-coal p-5 text-cream sm:p-7 md:grid-cols-[200px_1fr]">
        <div className="relative aspect-square overflow-hidden rounded-[20px] bg-white/10">
          {art ? <Image src={art} alt="" fill sizes="200px" className="object-cover" /> : null}
        </div>
        <div className="min-w-0">
          <div className="flex flex-wrap gap-2">
            <Chip tone={course.isPublished ? "ok" : "muted"}>{course.isPublished ? "Live on website & app" : "Draft — hidden"}</Chip>
            <Chip tone="accent">{course.priceInr ? formatRupees(course.priceInr) : "Free"}</Chip>
          </div>
          <h1 className="mt-3 font-serif text-[40px] leading-none tracking-[-0.02em] sm:text-[52px]">{course.title}</h1>
          <p className="mt-2 text-[15px] text-[#bdb4a7]">
            Class {course.classLevel} · {course.medium}
            {course.teachers.length ? ` · ${course.teachers.join(", ")}` : ""} · ID {course.courseCode}
          </p>
          <dl className="mt-5 flex flex-wrap gap-x-8 gap-y-3">
            {[
              [chapters.length, "chapters"],
              [lessons.length, "lectures"],
              [withVideo, "with video"],
              [course.enrolledCount, "students"],
            ].map(([v, l]) => (
              <div key={String(l)}>
                <dd className="font-serif text-[32px] leading-none">{v}</dd>
                <dt className="text-sm text-[#bdb4a7]">{l}</dt>
              </div>
            ))}
          </dl>
          <div className="mt-6 flex flex-wrap gap-2">
            <Modal
              title="Edit course details"
              wide
              triggerClassName="inline-flex h-10 items-center gap-2 rounded-full bg-saffron px-5 text-sm font-bold text-coal hover:bg-cream"
              triggerLabel={
                <>
                  <IconPencil size={16} />
                  Edit details
                </>
              }
            >
              <CourseForm course={course} />
            </Modal>
            {slug ? (
              <Link
                href={`/course/${slug}`}
                target="_blank"
                className="inline-flex h-10 items-center gap-2 rounded-full border border-white/25 px-5 text-sm font-semibold text-cream hover:bg-white/10"
              >
                <IconExternal size={16} />
                View on website
              </Link>
            ) : null}
            <ConfirmDelete
                onDark
                action={deleteCourseAction}
                fields={{ id: course.id, from: "detail" }}
                label="Delete course"
                title="Delete this course?"
                message={
                  <>
                    <strong className="text-coal">{course.title}</strong> and its {chapters.length} chapters and{" "}
                    {lessons.length} lectures will be removed.
                    {course.enrolledCount ? ` ${course.enrolledCount} enrolled students will lose access.` : ""} To hide it
                    for now, untick Published in Edit details instead.
                  </>
                }
                confirmLabel="Delete course"
              />
          </div>
        </div>
      </section>

      {/* Content */}
      <div className="mt-10 flex flex-wrap items-end justify-between gap-4">
        <div>
          <h2 className="font-serif text-[36px] leading-none">Course content</h2>
          <p className="mt-1.5 text-[15px] text-taupe">
            Chapters in teaching order. Each crash course chapter has one lecture and one practice session.
          </p>
        </div>
        <AddChapter courseId={course.id} subject={defaultSubject} />
      </div>

      {chapters.length === 0 ? (
        <div className="mt-6 rounded-[22px] border border-dashed border-sand bg-cream px-6 py-12 text-center">
          <p className="font-serif text-3xl">No chapters yet</p>
          <p className="mt-2 text-taupe">Add the first chapter, then add its lectures.</p>
        </div>
      ) : (
        subjects.map((subject) => (
          <section key={subject.id} className="mt-6">
            {subjects.length > 1 ? (
              <p className="mb-3 text-xs font-bold uppercase tracking-[0.14em] text-clay">{subject.name}</p>
            ) : null}
            <div className="flex flex-col gap-3">
              {subject.chapters.map((chapter, ci) => (
                <details
                  key={chapter.id}
                  open={ci === 0}
                  className="group overflow-hidden rounded-[20px] border border-sand bg-cream [&_summary::-webkit-details-marker]:hidden"
                >
                  <summary className="flex cursor-pointer list-none flex-wrap items-center gap-3 px-4 py-3.5 sm:px-5">
                    <span className="flex size-10 shrink-0 items-center justify-center rounded-xl bg-primary-soft font-semibold tabular-nums text-clay">
                      {String(ci + 1).padStart(2, "0")}
                    </span>
                    <span className="min-w-0 flex-1">
                      <span className="block truncate text-[16px] font-semibold text-coal">{chapter.title}</span>
                      <span className="text-sm text-taupe">
                        {chapter.lessons.length} lecture{chapter.lessons.length === 1 ? "" : "s"}
                        {" · "}
                        {chapter.lessons.filter((l) => l.videoRef || l.storagePath).length} with video
                      </span>
                    </span>
                    <span className="text-taupe transition-transform group-open:rotate-180">
                      <IconChevronDown size={20} />
                    </span>
                  </summary>

                  {/* Chapter toolbar */}
                  <div className="flex flex-wrap items-center gap-2 border-t border-sand bg-paper/60 px-4 py-2.5 sm:px-5">
                    <Modal
                      title={`Add a lecture to ${chapter.title}`}
                      wide
                      triggerClassName="inline-flex h-9 items-center gap-1.5 rounded-full bg-clay px-4 text-sm font-semibold text-white hover:bg-coal"
                      triggerLabel={
                        <>
                          <IconPlus size={16} />
                          Add lecture
                        </>
                      }
                    >
                      <LectureForm courseId={course.id} chapterId={chapter.id} />
                    </Modal>
                    <Modal
                      title="Rename chapter"
                      triggerClassName={ghost}
                      triggerLabel={
                        <>
                          <IconPencil size={15} />
                          Rename
                        </>
                      }
                    >
                      <ModalForm action={renameChapterAction}>
                        <input type="hidden" name="id" value={chapter.id} />
                        <input type="hidden" name="courseId" value={course.id} />
                        <Field label="Chapter name" name="title" defaultValue={chapter.title} required />
                        <ModalActions>Save name</ModalActions>
                      </ModalForm>
                    </Modal>
                    <span className="ml-auto flex items-center gap-1">
                      {(["up", "down"] as const).map((dir) => (
                        <form key={dir} action={moveChapterAction}>
                          <input type="hidden" name="id" value={chapter.id} />
                          <input type="hidden" name="courseId" value={course.id} />
                          <input type="hidden" name="direction" value={dir} />
                          <button
                            type="submit"
                            disabled={dir === "up" ? ci === 0 : ci === subject.chapters.length - 1}
                            aria-label={`Move ${dir}`}
                            title={`Move ${dir}`}
                            className={`${iconBtn} disabled:opacity-30`}
                          >
                            <span className={dir === "down" ? "rotate-180" : ""}>
                              <IconArrowUp size={18} />
                            </span>
                          </button>
                        </form>
                      ))}
                      <ConfirmDelete
                        compact
                        label="Delete chapter"
                        action={deleteChapterAction}
                        fields={{ id: chapter.id, courseId: course.id }}
                        title="Delete this chapter?"
                        message={
                          <>
                            <strong className="text-coal">{chapter.title}</strong>
                            {chapter.lessons.length
                              ? ` and its ${chapter.lessons.length} lecture${chapter.lessons.length === 1 ? "" : "s"} (with their notes) will be removed.`
                              : " will be removed."}
                          </>
                        }
                        confirmLabel="Delete chapter"
                      />
                    </span>
                  </div>

                  {/* Lectures */}
                  {chapter.lessons.length === 0 ? (
                    <p className="border-t border-sand px-5 py-5 text-sm text-taupe">No lectures in this chapter yet.</p>
                  ) : (
                    <ul className="divide-y divide-sand border-t border-sand">
                      {chapter.lessons.map((lesson) => {
                        const hasVideo = Boolean(lesson.videoRef || lesson.storagePath);
                        return (
                          <li key={lesson.id} className="px-4 py-3 sm:px-5">
                            <div className="flex flex-wrap items-center gap-3">
                              <span
                                className={`flex size-9 shrink-0 items-center justify-center rounded-full ${
                                  hasVideo ? "bg-coal text-cream" : "bg-paper text-taupe"
                                }`}
                              >
                                <IconPlay size={14} />
                              </span>
                              <div className="min-w-0 flex-1">
                                <p className="truncate font-medium text-coal">{lesson.title}</p>
                                <div className="mt-1 flex flex-wrap gap-1.5">
                                  {hasVideo ? <Chip tone="ok">Video linked</Chip> : <Chip tone="warn">No video yet</Chip>}
                                  {lesson.resources.length ? <Chip tone="accent">Notes linked</Chip> : null}
                                  <Chip tone={lesson.isPublished ? "ok" : "muted"}>{lesson.isPublished ? "Published" : "Draft"}</Chip>
                                  {lesson.isDemo ? <Chip tone="accent">Free preview</Chip> : null}
                                </div>
                              </div>
                              <Modal
                                title="Edit lecture"
                                wide
                                triggerClassName={ghost}
                                triggerLabel={
                                  <>
                                    <IconPencil size={15} />
                                    Edit
                                  </>
                                }
                              >
                                <LectureForm courseId={course.id} chapterId={chapter.id} lesson={lesson} />
                              </Modal>
                              <ConfirmDelete
                                compact
                                label="Delete lecture"
                                action={deleteLectureAction}
                                fields={{ id: lesson.id, courseId: course.id }}
                                title="Delete this lecture?"
                                message={
                                  <>
                                    <strong className="text-coal">{lesson.title}</strong> will be removed for every student,
                                    with its notes and doubts.
                                  </>
                                }
                                confirmLabel="Delete lecture"
                              />
                            </div>
                            {lesson.resources.length ? (
                              <ul className="mt-2 flex flex-col gap-1 pl-12">
                                {lesson.resources.map((r) => (
                                  <li key={r.id} className="flex items-center gap-2 text-sm text-taupe">
                                    <IconFile size={15} />
                                    <span className="min-w-0 flex-1 truncate">
                                      {r.title} · {r.source === "gdrive" ? "Google Drive" : "Uploaded PDF"}
                                    </span>
                                    <ConfirmDelete
                                      compact
                                      label="Remove notes"
                                      action={deleteNotesAction}
                                      fields={{ lessonId: lesson.id, resourceId: r.id, courseId: course.id }}
                                      title="Remove these notes?"
                                      message={
                                        <>
                                          <strong className="text-coal">{r.title}</strong> will no longer open for students.
                                          The file in Google Drive is not touched.
                                        </>
                                      }
                                      confirmLabel="Remove notes"
                                    />
                                  </li>
                                ))}
                              </ul>
                            ) : null}
                          </li>
                        );
                      })}
                    </ul>
                  )}
                </details>
              ))}
            </div>
          </section>
        ))
      )}

      <div className="mt-4">
        <AddChapter courseId={course.id} subject={defaultSubject} wide />
      </div>
    </>
  );
}

function AddChapter({ courseId, subject, wide = false }: { courseId: string; subject: string; wide?: boolean }) {
  return (
    <Modal
      title="Add a chapter"
      triggerClassName={
        wide
          ? "flex h-14 w-full items-center justify-center gap-2 rounded-[20px] border border-dashed border-sand bg-cream text-[15px] font-semibold text-taupe hover:border-clay hover:text-clay"
          : "inline-flex h-11 items-center gap-2 rounded-full bg-coal px-5 text-sm font-semibold text-cream hover:bg-clay"
      }
      triggerLabel={
        <>
          <IconPlus size={18} />
          Add chapter
        </>
      }
    >
      <ModalForm action={addChapterAction}>
        <input type="hidden" name="courseId" value={courseId} />
        <Field label="Chapter name" name="title" placeholder="Ray Optics" required />
        <Field label="Subject" name="subject" defaultValue={subject} hint="Chapters are grouped by subject." />
        <ModalActions>Add chapter</ModalActions>
      </ModalForm>
    </Modal>
  );
}
