import { Card, EmptyRow, PageHeader, Pill } from "@/components/admin/AdminChrome";
import { Field, SelectField } from "@/components/admin/Fields";
import { formatRupees } from "@/lib/admin/format";
import { listCourses } from "@/lib/admin/data";
import { deleteCourseAction, saveCourseAction } from "./actions";

export default async function AdminCoursesPage() {
  const courses = await listCourses();

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
                      <td className="py-3 text-right">
                        <form action={deleteCourseAction}>
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
          <h2 className="mb-1 font-semibold text-navy">Add a course</h2>
          <p className="mb-4 text-xs text-muted">
            Published courses appear on the website and in the app; untick to save a draft.
          </p>
          <form action={saveCourseAction} className="space-y-3">
            <Field label="Title" name="title" placeholder="Class 11 Science Batch" required />
            <div className="grid grid-cols-2 gap-3">
              <Field label="Class" name="classLevel" type="number" defaultValue="10" required />
              <SelectField label="Medium" name="medium" options={["Hindi", "English"]} />
            </div>
            <div className="grid grid-cols-2 gap-3">
              <Field label="Price (₹)" name="priceInr" type="number" defaultValue="2999" required />
              <Field
                label="Before discount (₹)"
                name="originalPriceInr"
                type="number"
                defaultValue="4999"
              />
            </div>
            <Field
              label="Subjects"
              name="subjects"
              placeholder="Physics, Chemistry, Maths"
              hint="Comma separated"
            />
            <Field
              label="Teachers"
              name="teachers"
              placeholder="Amit Sir, Neha Ma'am"
              hint="Comma separated"
            />
            <label className="flex items-center gap-2 pt-1 text-sm text-navy">
              <input type="checkbox" name="isPublished" defaultChecked className="size-4" />
              Publish immediately
            </label>
            <button
              type="submit"
              className="mt-2 w-full rounded-xl bg-primary px-4 py-2.5 text-sm font-semibold text-white transition-colors hover:bg-primary-dark"
            >
              Save course
            </button>
          </form>
        </Card>
      </div>
    </>
  );
}
