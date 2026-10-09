import { Card, PageHeader } from "@/components/admin/AdminChrome";
import { describeAudience, formatWhen } from "@/lib/admin/format";
import { listCourses, listNotifications } from "@/lib/admin/data";
import { sendNotificationAction } from "./actions";

export default async function AdminNotificationsPage() {
  const [notifications, courses] = await Promise.all([
    listNotifications(),
    listCourses(),
  ]);

  return (
    <>
      <PageHeader
        title="Notifications"
        description="Push a notice to every student, a class, a course or one student."
      />

      <div className="grid gap-4 lg:grid-cols-[1fr_1.3fr]">
        <Card>
          <h2 className="mb-1 font-semibold text-navy">Compose</h2>
          <p className="mb-4 text-xs text-muted">
            Sending writes a row to <code>notifications</code>, which the app receives over a
            realtime subscription, and hands it to the <code>send-push</code> Edge Function for
            FCM delivery.
          </p>
          <form action={sendNotificationAction} className="space-y-3">
            <label className="block">
              <span className="text-xs font-medium text-navy">Title</span>
              <input
                name="title"
                required
                placeholder="Class timing changed"
                className="mt-1 w-full rounded-xl border border-border bg-surface px-3 py-2 text-sm text-navy outline-none focus:border-primary"
              />
            </label>
            <label className="block">
              <span className="text-xs font-medium text-navy">Message</span>
              <textarea
                name="body"
                required
                rows={4}
                placeholder="Tomorrow's Mathematics class moves to 7:00 PM."
                className="mt-1 w-full resize-y rounded-xl border border-border bg-surface px-3 py-2 text-sm text-navy outline-none focus:border-primary"
              />
            </label>
            <div className="grid grid-cols-2 gap-3">
              <label className="block">
                <span className="text-xs font-medium text-navy">Audience</span>
                <select
                  name="audienceKind"
                  className="mt-1 w-full rounded-xl border border-border bg-surface px-3 py-2 text-sm text-navy outline-none focus:border-primary"
                >
                  <option value="all">Everyone</option>
                  <option value="class">A class</option>
                  <option value="course">A course</option>
                  <option value="student">One student</option>
                </select>
              </label>
              <label className="block">
                <span className="text-xs font-medium text-navy">Target</span>
                <input
                  name="audienceValue"
                  list="audience-options"
                  placeholder="10 / course id / name"
                  className="mt-1 w-full rounded-xl border border-border bg-surface px-3 py-2 text-sm text-navy outline-none focus:border-primary"
                />
                <datalist id="audience-options">
                  {["9", "10", "11", "12"].map((level) => (
                    <option key={level} value={level} />
                  ))}
                  {courses.map((course) => (
                    <option key={course.id} value={course.id} />
                  ))}
                </datalist>
              </label>
            </div>
            <p className="text-xs text-muted">Leave the target empty when sending to everyone.</p>

            <label className="block">
              <span className="text-xs font-medium text-navy">Deep link</span>
              <input
                name="deepLink"
                placeholder="/course/class-10-complete-batch"
                className="mt-1 w-full rounded-xl border border-border bg-surface px-3 py-2 text-sm text-navy outline-none focus:border-primary"
              />
              <span className="mt-1 block text-xs text-muted">
                Optional. Where tapping the notification takes the student in the app.
              </span>
            </label>

            <label className="flex items-center gap-2 pt-1 text-sm text-navy">
              <input type="checkbox" name="sendPush" defaultChecked className="size-4" />
              Also send as a push notification
            </label>
            <p className="text-xs text-muted">
              Unchecked, it appears only in the app&rsquo;s notification list.
            </p>

            <button
              type="submit"
              className="mt-2 w-full rounded-xl bg-primary px-4 py-2.5 text-sm font-semibold text-white transition-colors hover:bg-primary-dark"
            >
              Send notification
            </button>
          </form>
        </Card>

        <Card>
          <h2 className="mb-4 font-semibold text-navy">Sent</h2>
          <ul className="divide-y divide-border">
            {notifications.map((item) => (
              <li key={item.id} className="py-3">
                <div className="flex items-start justify-between gap-3">
                  <p className="font-medium text-navy">{item.title}</p>
                  <span className="shrink-0 text-xs text-muted">{formatWhen(item.sentAt)}</span>
                </div>
                <p className="mt-1 text-sm text-muted">{item.body}</p>
                <p className="mt-1.5 text-xs text-muted">
                  {describeAudience(item.audienceKind, item.audienceValue)} · sent by {item.sentBy}
                </p>
              </li>
            ))}
          </ul>
        </Card>
      </div>
    </>
  );
}
