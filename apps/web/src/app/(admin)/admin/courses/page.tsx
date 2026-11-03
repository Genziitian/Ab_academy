import Image from "next/image";
import Link from "next/link";
import { EmptyRow, PageHeader } from "@/components/admin/AdminChrome";
import { IconPlus } from "@/components/admin/AdminIcons";
import { ConfirmDelete, Modal } from "@/components/admin/Dialog";
import { formatRupees } from "@/lib/admin/format";
import { listCourses, listLessons } from "@/lib/admin/data";
import { courseArt, thumbnailGradient } from "@/lib/courses";
import { deleteCourseAction } from "./actions";
import { CourseForm } from "./CourseForm";

export const metadata = { title: "Courses" };

const HUES = [20, 150, 270, 200, 330, 60];

export default async function AdminCoursesPage() {
  const [courses, lessons] = await Promise.all([listCourses(), listLessons()]);

  const stats = new Map<string, { chapters: Set<string>; lectures: number; live: number }>();
  for (const l of lessons) {
    const s = stats.get(l.courseId) ?? { chapters: new Set(), lectures: 0, live: 0 };
    s.chapters.add(l.chapterId);
    s.lectures += 1;
    if (l.isPublished && (l.videoRef || l.storagePath)) s.live += 1;
    stats.set(l.courseId, s);
  }

  return (
    <>
      <PageHeader
        title="Courses"
        description="Every course on the website and in the app. Open one to add chapters, lectures and notes."
        action={
          <Modal
            title="New course"
            wide
            triggerClassName="inline-flex h-12 items-center gap-2 rounded-full bg-clay px-6 text-[15px] font-semibold text-white hover:bg-coal"
            triggerLabel={
              <>
                <IconPlus size={18} />
                New course
              </>
            }
          >
            <CourseForm />
          </Modal>
        }
      />

      {courses.length === 0 ? (
        <EmptyRow>No courses yet — create the first one.</EmptyRow>
      ) : (
        <div className="grid gap-5 sm:grid-cols-2 xl:grid-cols-3">
          {courses.map((course, i) => {
            const s = stats.get(course.id);
            const art = course.thumbnailUrl ?? courseArt({ subjects: course.subjects, price: course.priceInr });
            return (
              <article
                key={course.id}
                className="group flex flex-col overflow-hidden rounded-[22px] border border-sand bg-cream transition hover:-translate-y-0.5 hover:shadow-[0_18px_40px_rgba(28,24,20,0.1)]"
              >
                <Link href={`/admin/courses/${course.id}`} className="relative block aspect-[16/8] overflow-hidden">
                  <div className="absolute inset-0" style={{ background: thumbnailGradient(HUES[i % HUES.length]) }} />
                  {art ? (
                    <Image src={art} alt="" fill sizes="(min-width: 1280px) 400px, 50vw" className="object-cover" />
                  ) : null}
                  <span
                    className={`absolute left-4 top-4 rounded-full px-3 py-1 text-xs font-bold uppercase tracking-[0.08em] ${
                      course.isPublished ? "bg-[#e9f6ee] text-[#1d6b3d]" : "bg-cream text-taupe"
                    }`}
                  >
                    {course.isPublished ? "Live" : "Draft"}
                  </span>
                  <span className="absolute right-4 top-4 rounded-full bg-coal/80 px-3 py-1 text-sm font-bold text-cream">
                    {course.priceInr ? formatRupees(course.priceInr) : "Free"}
                  </span>
                </Link>
                <div className="flex flex-1 flex-col p-5">
                  <Link href={`/admin/courses/${course.id}`} className="text-lg font-semibold leading-snug text-coal hover:text-clay">
                    {course.title}
                  </Link>
                  <p className="mt-1 text-sm text-taupe">
                    Class {course.classLevel} · {course.medium}
                    {course.teachers.length ? ` · ${course.teachers.join(", ")}` : ""}
                  </p>
                  <dl className="mt-4 grid grid-cols-3 gap-2">
                    {[
                      [s?.chapters.size ?? 0, "Chapters"],
                      [s?.lectures ?? 0, "Lectures"],
                      [course.enrolledCount, "Students"],
                    ].map(([value, label]) => (
                      <div key={String(label)} className="rounded-2xl bg-paper px-2 py-3 text-center">
                        <dd className="font-serif text-[28px] leading-none text-coal">{value}</dd>
                        <dt className="mt-1 text-xs text-taupe">{label}</dt>
                      </div>
                    ))}
                  </dl>
                  <div className="mt-auto flex items-center gap-2 pt-5">
                    <Link
                      href={`/admin/courses/${course.id}`}
                      className="flex h-10 flex-1 items-center justify-center rounded-full bg-coal text-sm font-semibold text-cream hover:bg-clay"
                    >
                      Manage content
                    </Link>
                    <ConfirmDelete
                      compact
                      label={`Delete ${course.title}`}
                      action={deleteCourseAction}
                      fields={{ id: course.id }}
                      title="Delete this course?"
                      message={
                        <>
                          <strong className="text-coal">{course.title}</strong> and all its chapters, lectures and notes
                          will be removed.
                          {course.enrolledCount
                            ? ` ${course.enrolledCount} enrolled student${course.enrolledCount === 1 ? "" : "s"} will lose access.`
                            : ""}{" "}
                          To hide it for now, edit the course and untick Published instead.
                        </>
                      }
                      confirmLabel="Delete course"
                    />
                  </div>
                </div>
              </article>
            );
          })}
        </div>
      )}
    </>
  );
}
