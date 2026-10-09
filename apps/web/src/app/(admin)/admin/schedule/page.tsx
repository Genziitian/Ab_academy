import { Card, EmptyRow, PageHeader, Pill } from "@/components/admin/AdminChrome";
import { formatWhen } from "@/lib/admin/format";
import { listCourses, listSessions } from "@/lib/admin/data";
import { deleteSessionAction, saveSessionAction } from "./actions";

export default async function AdminSchedulePage() {
  const [sessions, courses] = await Promise.all([listSessions(), listCourses()]);
  const courseName = (id: string) => courses.find((c) => c.id === id)?.title ?? id;

  const upcoming = sessions.filter((s) => s.status !== "ended");
  const past = sessions.filter((s) => s.status === "ended");

  return (
    <>
      <PageHeader
        title="Schedule"
        description="Live classes and test deadlines. These fill the student calendar and the Live tab."
      />

      <div className="grid gap-4 lg:grid-cols-[1.4fr_1fr]">
        <div className="space-y-4">
          <Card>
            <h2 className="mb-4 font-semibold text-navy">Upcoming</h2>
            {upcoming.length === 0 ? (
              <EmptyRow>Nothing scheduled yet.</EmptyRow>
            ) : (
              <ul className="divide-y divide-border">
                {upcoming.map((session) => (
                  <li key={session.id} className="flex items-start justify-between gap-3 py-3">
                    <div className="min-w-0">
                      <div className="flex flex-wrap items-center gap-2">
                        <p className="font-medium text-navy">{session.title}</p>
                        <Pill status={session.status} />
                      </div>
                      <p className="mt-1 text-xs text-muted">
                        {courseName(session.courseId)} · {session.subject} · {session.teacher}
                      </p>
                      <p className="mt-0.5 text-xs text-muted">
                        {formatWhen(session.startsAt)} · {session.durationMinutes} min
                      </p>
                    </div>
                    <form action={deleteSessionAction}>
                      <input type="hidden" name="id" value={session.id} />
                      <button
                        type="submit"
                        className="text-xs font-medium text-pink hover:underline"
                      >
                        Cancel
                      </button>
                    </form>
                  </li>
                ))}
              </ul>
            )}
          </Card>

          <Card>
            <h2 className="mb-4 font-semibold text-navy">Past classes</h2>
            {past.length === 0 ? (
              <EmptyRow>No past classes.</EmptyRow>
            ) : (
              <ul className="divide-y divide-border">
                {past.map((session) => (
                  <li key={session.id} className="py-3">
                    <p className="text-sm font-medium text-navy">{session.title}</p>
                    <p className="text-xs text-muted">
                      {formatWhen(session.startsAt)} · recording available
                    </p>
                  </li>
                ))}
              </ul>
            )}
          </Card>
        </div>

        <Card>
          <h2 className="mb-4 font-semibold text-navy">Schedule a class</h2>
          <form action={saveSessionAction} className="space-y-3">
            <label className="block">
              <span className="text-xs font-medium text-navy">Title</span>
              <input
                name="title"
                required
                placeholder="Trigonometry — doubt session"
                className="mt-1 w-full rounded-xl border border-border bg-surface px-3 py-2 text-sm text-navy outline-none focus:border-primary"
              />
            </label>
            <label className="block">
              <span className="text-xs font-medium text-navy">Course</span>
              <select
                name="courseId"
                className="mt-1 w-full rounded-xl border border-border bg-surface px-3 py-2 text-sm text-navy outline-none focus:border-primary"
              >
                {courses.map((course) => (
                  <option key={course.id} value={course.id}>
                    {course.title}
                  </option>
                ))}
              </select>
            </label>
            <div className="grid grid-cols-2 gap-3">
              <label className="block">
                <span className="text-xs font-medium text-navy">Subject</span>
                <input
                  name="subject"
                  required
                  defaultValue="Mathematics"
                  className="mt-1 w-full rounded-xl border border-border bg-surface px-3 py-2 text-sm text-navy outline-none focus:border-primary"
                />
              </label>
              <label className="block">
                <span className="text-xs font-medium text-navy">Teacher</span>
                <input
                  name="teacher"
                  required
                  defaultValue="Amit Sir"
                  className="mt-1 w-full rounded-xl border border-border bg-surface px-3 py-2 text-sm text-navy outline-none focus:border-primary"
                />
              </label>
            </div>
            <div className="grid grid-cols-2 gap-3">
              <label className="block">
                <span className="text-xs font-medium text-navy">Starts at</span>
                <input
                  name="startsAt"
                  type="datetime-local"
                  required
                  defaultValue="2026-09-18T18:00"
                  className="mt-1 w-full rounded-xl border border-border bg-surface px-3 py-2 text-sm text-navy outline-none focus:border-primary"
                />
              </label>
              <label className="block">
                <span className="text-xs font-medium text-navy">Minutes</span>
                <input
                  name="durationMinutes"
                  type="number"
                  defaultValue="60"
                  className="mt-1 w-full rounded-xl border border-border bg-surface px-3 py-2 text-sm text-navy outline-none focus:border-primary"
                />
              </label>
            </div>
            <button
              type="submit"
              className="mt-2 w-full rounded-xl bg-primary px-4 py-2.5 text-sm font-semibold text-white transition-colors hover:bg-primary-dark"
            >
              Add to schedule
            </button>
          </form>
        </Card>
      </div>
    </>
  );
}
