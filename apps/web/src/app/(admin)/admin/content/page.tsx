import Link from "next/link";
import { Card, EmptyRow, PageHeader, Pill } from "@/components/admin/AdminChrome";
import {
  CheckboxField,
  Field,
  SelectField,
  SubmitButton,
} from "@/components/admin/Fields";
import { listCourses, listLessons } from "@/lib/admin/data";
import {
  addResourceAction,
  deleteLessonAction,
  deleteResourceAction,
  saveLessonAction,
} from "./actions";

export const metadata = { title: "Content" };

function formatDuration(seconds: number | null) {
  if (!seconds) return "—";
  const m = Math.round(seconds / 60);
  if (m < 60) return `${m} min`;
  return `${Math.floor(m / 60)}h ${m % 60}m`;
}

function formatSize(bytes: number | null) {
  if (!bytes) return "";
  const mb = bytes / 1_048_576;
  return mb >= 1 ? `${mb.toFixed(1)} MB` : `${Math.round(bytes / 1024)} KB`;
}

export default async function AdminContentPage({
  searchParams,
}: {
  searchParams: Promise<{ course?: string }>;
}) {
  const { course: courseFilter } = await searchParams;

  const [courses, lessons] = await Promise.all([
    listCourses(),
    listLessons(courseFilter),
  ]);

  return (
    <>
      <PageHeader
        title="Content"
        description="Recordings, videos and notes. A lesson holds the video; notes attach to it as PDFs."
      />

      <div className="mb-4 flex flex-wrap gap-2">
        <Link
          href="/admin/content"
          className={`rounded-full px-3.5 py-1.5 text-sm font-medium transition-colors ${
            !courseFilter
              ? "bg-primary text-white"
              : "border border-border bg-surface text-muted hover:text-navy"
          }`}
        >
          All courses
        </Link>
        {courses.map((course) => (
          <Link
            key={course.id}
            href={`/admin/content?course=${course.id}`}
            className={`rounded-full px-3.5 py-1.5 text-sm font-medium transition-colors ${
              courseFilter === course.id
                ? "bg-primary text-white"
                : "border border-border bg-surface text-muted hover:text-navy"
            }`}
          >
            {course.title}
          </Link>
        ))}
      </div>

      <div className="grid gap-4 lg:grid-cols-[1.5fr_1fr]">
        <div className="space-y-4">
          {lessons.length === 0 ? (
            <Card>
              <EmptyRow>
                No lessons yet. Add the first recording on the right.
              </EmptyRow>
            </Card>
          ) : (
            lessons.map((lesson) => (
              <Card key={lesson.id}>
                <div className="flex flex-wrap items-start justify-between gap-3">
                  <div className="min-w-0">
                    <div className="flex flex-wrap items-center gap-2">
                      <h3 className="font-semibold text-navy">{lesson.title}</h3>
                      <Pill status={lesson.isPublished ? "published" : "draft"} />
                      {lesson.isDemo ? (
                        <span className="rounded-full bg-teal/15 px-2.5 py-1 text-xs font-semibold text-teal">
                          free preview
                        </span>
                      ) : null}
                    </div>
                    <p className="mt-1 text-xs text-muted">
                      {lesson.courseTitle} · {lesson.subjectName} ·{" "}
                      {lesson.chapterTitle}
                    </p>
                    <p className="mt-1 text-xs text-muted">
                      {lesson.lessonType} · {formatDuration(lesson.durationSeconds)}
                      {lesson.videoProvider
                        ? ` · ${lesson.videoProvider}${
                            lesson.videoRef ? ` (${lesson.videoRef})` : ""
                          }`
                        : " · no video attached"}
                      {lesson.isDownloadable ? " · downloadable" : ""}
                    </p>
                  </div>
                  <form action={deleteLessonAction}>
                    <input type="hidden" name="id" value={lesson.id} />
                    <button
                      type="submit"
                      className="text-xs font-medium text-pink hover:underline"
                    >
                      Delete
                    </button>
                  </form>
                </div>

                {/* Notes attached to this lesson. */}
                <div className="mt-4 border-t border-border pt-4">
                  <p className="text-xs font-semibold tracking-wide text-muted uppercase">
                    Notes
                  </p>

                  {lesson.resources.length === 0 ? (
                    <p className="mt-2 text-xs text-muted">
                      No notes attached yet.
                    </p>
                  ) : (
                    <ul className="mt-2 divide-y divide-border">
                      {lesson.resources.map((resource) => (
                        <li
                          key={resource.id}
                          className="flex items-center justify-between gap-3 py-2"
                        >
                          <div className="min-w-0">
                            <p className="truncate text-sm text-navy">
                              {resource.title}
                            </p>
                            <p className="text-xs text-muted">
                              {resource.source === "gdrive" ? "Google Drive" : resource.resourceType}
                              {formatSize(resource.sizeBytes)
                                ? ` · ${formatSize(resource.sizeBytes)}`
                                : ""}
                            </p>
                          </div>
                          <form action={deleteResourceAction}>
                            <input
                              type="hidden"
                              name="lessonId"
                              value={lesson.id}
                            />
                            <input
                              type="hidden"
                              name="resourceId"
                              value={resource.id}
                            />
                            <button
                              type="submit"
                              className="text-xs font-medium text-pink hover:underline"
                            >
                              Remove
                            </button>
                          </form>
                        </li>
                      ))}
                    </ul>
                  )}

                  <form
                    action={addResourceAction}
                    className="mt-3 flex flex-wrap items-end gap-2"
                  >
                    <input type="hidden" name="lessonId" value={lesson.id} />
                    <input
                      name="title"
                      placeholder="Notes title"
                      className="min-w-0 flex-1 rounded-xl border border-border bg-surface px-3 py-2 text-sm text-navy outline-none focus:border-primary"
                    />
                    <input
                      name="driveLink"
                      placeholder="Google Drive link"
                      className="min-w-0 flex-1 rounded-xl border border-border bg-surface px-3 py-2 text-sm text-navy outline-none focus:border-primary"
                    />
                    <span className="text-xs text-muted">or</span>
                    <input
                      type="file"
                      name="file"
                      accept="application/pdf"
                      className="text-xs text-muted"
                    />
                    <button
                      type="submit"
                      className="rounded-xl border border-border bg-surface px-3 py-2 text-xs font-semibold text-navy transition-colors hover:bg-surface-soft"
                    >
                      Attach PDF
                    </button>
                  </form>
                </div>
              </Card>
            ))
          )}
        </div>

        <Card className="h-fit">
          <h2 className="mb-1 font-semibold text-navy">Add a lesson</h2>
          <p className="mb-4 text-xs text-muted">
            The subject and chapter are created if they do not exist yet, so you
            never have to set up the hierarchy first.
          </p>

          <form action={saveLessonAction} className="space-y-3">
            <Field
              label="Title"
              name="title"
              placeholder="Real Numbers — Euclid's lemma"
              required
            />

            <SelectField
              label="Course"
              name="courseId"
              options={courses.map((c) => ({ value: c.id, label: c.title }))}
            />

            <div className="grid grid-cols-2 gap-3">
              <Field
                label="Subject"
                name="subjectName"
                placeholder="Mathematics"
                required
              />
              <Field
                label="Chapter"
                name="chapterTitle"
                placeholder="Chapter 01 · Real Numbers"
                required
              />
            </div>

            <div className="grid grid-cols-2 gap-3">
              <SelectField
                label="Type"
                name="lessonType"
                options={["VIDEO", "LIVE", "PDF", "TEST", "ASSIGNMENT"]}
              />
              <Field
                label="Duration (min)"
                name="durationMinutes"
                type="number"
                min="0"
                defaultValue="45"
              />
            </div>

            <Field
              label="YouTube video id"
              name="videoRef"
              placeholder="dQw4w9WgXcQ"
              hint="Leave empty if you upload a file below instead."
            />

            <label className="block">
              <span className="text-xs font-medium text-navy">
                Or upload an mp4
              </span>
              <input
                type="file"
                name="videoFile"
                accept="video/mp4,video/webm"
                className="mt-1 w-full text-xs text-muted"
              />
              <span className="mt-1 block text-xs text-muted">
                Goes to the private lesson-videos bucket, played back over a
                signed URL. Max 2 GB.
              </span>
            </label>

            <div className="space-y-1 pt-1">
              <CheckboxField label="Publish now" name="isPublished" defaultChecked />
              <CheckboxField label="Free preview (no enrolment needed)" name="isDemo" />
              <CheckboxField label="Allow offline download" name="isDownloadable" />
            </div>

            <SubmitButton>Save lesson</SubmitButton>
          </form>
        </Card>
      </div>
    </>
  );
}
