import Link from "next/link";
import { Card, EmptyRow, PageHeader } from "@/components/admin/AdminChrome";
import { Field, SelectField } from "@/components/admin/Fields";
import { listCourses, listStudents } from "@/lib/admin/data";
import { formatWhen } from "@/lib/admin/format";
import { enrollAction, saveStudentAction, unenrollAction } from "./actions";

export const metadata = { title: "Students" };

export default async function AdminStudentsPage({
  searchParams,
}: {
  searchParams: Promise<{ q?: string; class?: string; edit?: string }>;
}) {
  const { q, class: classFilter, edit } = await searchParams;
  const classLevel = classFilter ? Number(classFilter) : undefined;

  const [students, courses] = await Promise.all([
    listStudents(q, classLevel),
    listCourses(),
  ]);

  const editing = edit ? students.find((s) => s.id === edit) : undefined;
  const classes = [9, 10, 11, 12];

  return (
    <>
      <PageHeader
        title="Students"
        description="Everyone who has signed up. Edit a profile or grant course access by hand."
      />

      {/* Search and class filter as a GET form, so the URL is shareable. */}
      <form className="mb-4 flex flex-wrap items-end gap-3">
        <label className="block">
          <span className="text-xs font-medium text-navy">Search</span>
          <input
            name="q"
            defaultValue={q ?? ""}
            placeholder="Name, phone, email or student code"
            className="mt-1 w-64 rounded-xl border border-border bg-surface px-3 py-2 text-sm text-navy outline-none focus:border-primary"
          />
        </label>
        <label className="block">
          <span className="text-xs font-medium text-navy">Class</span>
          <select
            name="class"
            defaultValue={classFilter ?? ""}
            className="mt-1 rounded-xl border border-border bg-surface px-3 py-2 text-sm text-navy outline-none focus:border-primary"
          >
            <option value="">All classes</option>
            {classes.map((c) => (
              <option key={c} value={c}>
                Class {c}
              </option>
            ))}
          </select>
        </label>
        <button
          type="submit"
          className="rounded-xl bg-primary px-4 py-2 text-sm font-semibold text-white transition-colors hover:bg-primary-dark"
        >
          Filter
        </button>
        {q || classFilter ? (
          <Link
            href="/admin/students"
            className="px-2 py-2 text-sm font-medium text-muted hover:text-navy"
          >
            Clear
          </Link>
        ) : null}
      </form>

      <div className="grid gap-4 lg:grid-cols-[1.6fr_1fr]">
        <Card>
          <h2 className="mb-4 font-semibold text-navy">
            {students.length} student{students.length === 1 ? "" : "s"}
          </h2>

          {students.length === 0 ? (
            <EmptyRow>No students match that filter.</EmptyRow>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full min-w-[42rem] text-left text-sm">
                <thead>
                  <tr className="border-b border-border text-xs tracking-wide text-muted uppercase">
                    <th className="pb-2 font-medium">Student</th>
                    <th className="pb-2 font-medium">Class</th>
                    <th className="pb-2 font-medium">Courses</th>
                    <th className="pb-2 font-medium">Joined</th>
                    <th className="pb-2" />
                  </tr>
                </thead>
                <tbody className="divide-y divide-border">
                  {students.map((student) => (
                    <tr key={student.id}>
                      <td className="py-3 pr-3">
                        <p className="font-medium text-navy">{student.fullName}</p>
                        <p className="font-mono text-xs text-primary">{student.studentCode}</p>
                        <p className="text-xs text-muted">
                          {student.phone ?? student.email ?? "no contact"}
                        </p>
                        {student.school ? (
                          <p className="text-xs text-muted">{student.school}</p>
                        ) : null}
                      </td>
                      <td className="py-3 pr-3 whitespace-nowrap text-navy">
                        {student.classLevel ? `Class ${student.classLevel}` : "—"}
                        {student.medium ? (
                          <span className="block text-xs text-muted">
                            {student.medium}
                            {student.stream ? ` · ${student.stream}` : ""}
                          </span>
                        ) : null}
                      </td>
                      <td className="py-3 pr-3">
                        {student.enrolledCourses.length === 0 ? (
                          <span className="text-xs text-muted">None</span>
                        ) : (
                          <ul className="space-y-1">
                            {student.enrolledCourses.map((course) => (
                              <li key={course} className="text-xs text-navy">
                                {course}
                              </li>
                            ))}
                          </ul>
                        )}
                      </td>
                      <td className="py-3 pr-3 text-xs whitespace-nowrap text-muted">
                        {formatWhen(student.createdAt)}
                      </td>
                      <td className="py-3 text-right">
                        <Link
                          href={`/admin/students?edit=${student.id}`}
                          className="text-xs font-medium text-primary hover:underline"
                        >
                          Edit
                        </Link>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </Card>

        <div className="space-y-4">
          {editing ? (
            <>
              <Card>
                <h2 className="mb-1 font-semibold text-navy">
                  Edit {editing.fullName}
                </h2>
                <p className="mb-4 text-xs text-muted">
                  Student code{" "}
                  <span className="font-mono text-primary">{editing.studentCode}</span>.
                  It, the phone and the email are fixed and cannot be changed
                  here.
                </p>
                <form action={saveStudentAction} className="space-y-3">
                  <input type="hidden" name="id" value={editing.id} />
                  <Field
                    label="Full name"
                    name="fullName"
                    defaultValue={editing.fullName}
                    required
                  />
                  <div className="grid grid-cols-2 gap-3">
                    <SelectField
                      label="Class"
                      name="classLevel"
                      defaultValue={String(editing.classLevel ?? "")}
                      options={[
                        { value: "", label: "—" },
                        ...classes.map((c) => ({
                          value: String(c),
                          label: `Class ${c}`,
                        })),
                      ]}
                    />
                    <SelectField
                      label="Medium"
                      name="medium"
                      defaultValue={editing.medium ?? ""}
                      options={[
                        { value: "", label: "—" },
                        { value: "Hindi", label: "Hindi" },
                        { value: "English", label: "English" },
                      ]}
                    />
                  </div>
                  <Field
                    label="Stream"
                    name="stream"
                    defaultValue={editing.stream ?? ""}
                    placeholder="Science / Commerce / Arts"
                  />
                  <Field
                    label="School"
                    name="school"
                    defaultValue={editing.school ?? ""}
                  />
                  <button
                    type="submit"
                    className="mt-2 w-full rounded-xl bg-primary px-4 py-2.5 text-sm font-semibold text-white transition-colors hover:bg-primary-dark"
                  >
                    Save student
                  </button>
                </form>
              </Card>

              <Card>
                <h2 className="mb-1 font-semibold text-navy">Course access</h2>
                <p className="mb-4 text-xs text-muted">
                  Granting access here creates an enrolment without an order, so
                  use it only for offline payments.
                </p>
                <form action={enrollAction} className="space-y-3">
                  <input type="hidden" name="studentId" value={editing.id} />
                  <SelectField
                    label="Grant access to"
                    name="courseId"
                    options={courses.map((c) => ({
                      value: c.id,
                      label: c.title,
                    }))}
                  />
                  <button
                    type="submit"
                    className="w-full rounded-xl border border-border bg-surface px-4 py-2.5 text-sm font-semibold text-navy transition-colors hover:bg-surface-soft"
                  >
                    Enrol student
                  </button>
                </form>

                {editing.enrolledCourses.length > 0 ? (
                  <ul className="mt-4 divide-y divide-border border-t border-border">
                    {editing.enrolledCourses.map((courseTitle) => {
                      const course = courses.find(
                        (c) => c.title === courseTitle || c.id === courseTitle,
                      );
                      return (
                        <li
                          key={courseTitle}
                          className="flex items-center justify-between gap-2 py-2.5"
                        >
                          <span className="text-sm text-navy">{courseTitle}</span>
                          {course ? (
                            <form action={unenrollAction}>
                              <input
                                type="hidden"
                                name="studentId"
                                value={editing.id}
                              />
                              <input
                                type="hidden"
                                name="courseId"
                                value={course.id}
                              />
                              <button
                                type="submit"
                                className="text-xs font-medium text-pink hover:underline"
                              >
                                Remove
                              </button>
                            </form>
                          ) : null}
                        </li>
                      );
                    })}
                  </ul>
                ) : null}

                <Link
                  href="/admin/students"
                  className="mt-4 block text-center text-xs font-medium text-muted hover:text-navy"
                >
                  Done editing
                </Link>
              </Card>
            </>
          ) : (
            <Card>
              <h2 className="mb-1 font-semibold text-navy">Edit a student</h2>
              <p className="text-xs text-muted">
                Pick <strong>Edit</strong> on any row to change their class and
                medium, or to grant course access by hand.
              </p>
              <p className="mt-4 text-xs text-muted">
                Students are created by signing up in the app — there is no
                &ldquo;add student&rdquo; form on purpose, because every account
                needs a real phone number or Google identity behind it.
              </p>
            </Card>
          )}
        </div>
      </div>
    </>
  );
}
