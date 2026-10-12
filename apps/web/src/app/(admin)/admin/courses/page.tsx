import Link from "next/link";
import { Card, EmptyRow, PageHeader, Pill } from "@/components/admin/AdminChrome";
import { Field, SelectField, TextAreaField } from "@/components/admin/Fields";
import { formatRupees } from "@/lib/admin/format";
import { listCourses } from "@/lib/admin/data";
import { deleteCourseAction, saveCourseAction } from "./actions";

export default async function AdminCoursesPage({
  searchParams,
}: {
  searchParams: Promise<{ edit?: string }>;
}) {
  const { edit } = await searchParams;
  const courses = await listCourses();
  const editing = edit ? courses.find((c) => c.id === edit) : undefined;

  return (
    <>
      <PageHeader
        title="Courses"
        description="Create a batch, set its price and decide whether students can see it."
      />

      <div className="grid gap-4 lg:grid-cols-[1.4fr_1fr]">
        <Card>
          <h2 className="mb-4 font-semibold text-navy">All courses</h2>
          {courses.length === 0 ? (
            <EmptyRow>No courses yet — add the first one.</EmptyRow>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full min-w-[34rem] text-left text-sm">
                <thead>
                  <tr className="border-b border-border text-xs tracking-wide text-muted uppercase">
                    <th className="pb-2 font-medium">Course</th>
                    <th className="pb-2 font-medium">Price</th>
                    <th className="pb-2 font-medium">Students</th>
                    <th className="pb-2 font-medium">Status</th>
                    <th className="pb-2" />
                  </tr>
                </thead>
                <tbody className="divide-y divide-border">
                  {courses.map((course) => (
                    <tr key={course.id}>
                      <td className="py-3 pr-3">
                        <p className="font-medium text-navy">{course.title}</p>
                        <p className="font-mono text-xs text-primary">{course.courseCode}</p>
                        <p className="text-xs text-muted">
                          Class {course.classLevel} · {course.medium} · {course.subjects.length}{" "}
                          subjects
                        </p>
                      </td>
                      <td className="py-3 pr-3 whitespace-nowrap text-navy">
                        {formatRupees(course.priceInr)}
                      </td>
                      <td className="py-3 pr-3 text-muted">{course.enrolledCount}</td>
                      <td className="py-3 pr-3">
                        <Pill status={course.isPublished ? "published" : "draft"} />
                      </td>
                      <td className="py-3 text-right whitespace-nowrap">
                        <Link
                          href={`/admin/courses?edit=${course.id}`}
                          className="mr-3 text-xs font-medium text-primary hover:underline"
                        >
                          Edit
                        </Link>
                        <form action={deleteCourseAction} className="inline">
                          <input type="hidden" name="id" value={course.id} />
                          <button
                            type="submit"
                            className="text-xs font-medium text-pink hover:underline"
                          >
                            Delete
                          </button>
                        </form>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </Card>

        <Card>
          <div className="mb-1 flex items-center justify-between gap-3">
            <h2 className="font-semibold text-navy">
              {editing ? `Edit ${editing.title}` : "Add a course"}
            </h2>
            {editing ? (
              <Link href="/admin/courses" className="text-xs font-medium text-muted hover:text-navy">
                Cancel
              </Link>
            ) : null}
          </div>
          <p className="mb-4 text-xs text-muted">
            {editing ? (
              <>
                Course ID <span className="font-mono text-primary">{editing.courseCode}</span> is
                fixed.{" "}
              </>
            ) : (
              "A random course ID is generated when you save. "
            )}
            Published courses appear on the website and in the app; untick to save a draft.
          </p>
          {/* key resets the uncontrolled inputs when switching courses. */}
          <form key={editing?.id ?? "new"} action={saveCourseAction} className="space-y-3">
            {editing ? <input type="hidden" name="id" value={editing.id} /> : null}
            <Field
              label="Title"
              name="title"
              placeholder="Class 11 Science Batch"
              defaultValue={editing?.title}
              required
            />
            <div className="grid grid-cols-2 gap-3">
              <Field
                label="Class"
                name="classLevel"
                type="number"
                defaultValue={String(editing?.classLevel ?? 12)}
                required
              />
              <SelectField
                label="Medium"
                name="medium"
                defaultValue={editing?.medium}
                options={["Hindi", "English", "Hindi + English"]}
              />
            </div>
            <div className="grid grid-cols-2 gap-3">
              <Field
                label="Price (₹)"
                name="priceInr"
                type="number"
                defaultValue={String(editing?.priceInr ?? 2999)}
                required
              />
              <Field
                label="Before discount (₹)"
                name="originalPriceInr"
                type="number"
                defaultValue={String(editing?.originalPriceInr ?? 4999)}
              />
            </div>
            <TextAreaField
              label="Description"
              name="description"
              placeholder="What the course covers, in one or two sentences."
              defaultValue={editing?.description}
            />
            <TextAreaField
              label="Highlights"
              name="highlights"
              placeholder={"Live classes with expert teachers\nPDF notes for every chapter"}
              defaultValue={editing?.highlights.join("\n")}
              hint="One per line"
              rows={4}
            />
            <Field
              label="Subjects"
              name="subjects"
              placeholder="Physics, Chemistry, Maths"
              defaultValue={editing?.subjects.join(", ")}
              hint="Comma separated"
            />
            <Field
              label="Teachers"
              name="teachers"
              placeholder="Amit Sir, Neha Ma'am"
              defaultValue={editing?.teachers.join(", ")}
              hint="Comma separated"
            />
            <label className="flex items-center gap-2 pt-1 text-sm text-navy">
              <input
                type="checkbox"
                name="isPublished"
                defaultChecked={editing ? editing.isPublished : true}
                className="size-4"
              />
              {editing ? "Published" : "Publish immediately"}
            </label>
            <button
              type="submit"
              className="mt-2 w-full rounded-xl bg-primary px-4 py-2.5 text-sm font-semibold text-white transition-colors hover:bg-primary-dark"
            >
              {editing ? "Save changes" : "Save course"}
            </button>
          </form>
        </Card>
      </div>
    </>
  );
}
