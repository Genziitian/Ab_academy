import Link from "next/link";
import { Card, PageHeader, Pill } from "@/components/admin/AdminChrome";
import { describeAudience, formatWhen } from "@/lib/admin/format";
import {
  getDashboardCounts,
  listNotifications,
  listSessions,
  listTickets,
} from "@/lib/admin/data";

export default async function AdminDashboard() {
  const [counts, allNotifications, allTickets, allSessions] = await Promise.all([
    getDashboardCounts(),
    listNotifications(),
    listTickets(),
    listSessions(),
  ]);

  const notifications = allNotifications.slice(0, 4);
  const openTickets = allTickets.filter(
    (t) => t.status === "open" || t.status === "in_progress",
  );
  const upcoming = allSessions.filter((s) => s.status !== "ended").slice(0, 4);

  const stats = [
    { label: "Courses", value: `${counts.publishedCourses}/${counts.courses}`, hint: "published" },
    { label: "Students", value: counts.students.toLocaleString("en-IN"), hint: "enrolled" },
    { label: "Upcoming classes", value: counts.upcomingSessions, hint: "scheduled" },
    { label: "Open tickets", value: counts.openTickets, hint: "awaiting reply" },
    { label: "Open doubts", value: counts.openDoubts, hint: "unanswered" },
    { label: "Lessons", value: counts.lessons, hint: "videos and notes" },
    { label: "Active popups", value: counts.activePopups, hint: "showing now" },
    { label: "Notifications", value: counts.notificationsSent, hint: "sent" },
  ];

  return (
    <>
      <PageHeader title="Dashboard" description="Everything happening across the academy today." />

      <div className="grid grid-cols-2 gap-4 lg:grid-cols-4">
        {stats.map((stat) => (
          <Card key={stat.label}>
            <p className="text-xs font-medium tracking-wide text-muted uppercase">{stat.label}</p>
            <p className="mt-2 text-3xl font-semibold tracking-tight text-navy">{stat.value}</p>
            <p className="mt-1 text-xs text-muted">{stat.hint}</p>
          </Card>
        ))}
      </div>

      <div className="mt-6 grid gap-4 lg:grid-cols-2">
        <Card>
          <div className="mb-4 flex items-center justify-between">
            <h2 className="font-semibold text-navy">Next live classes</h2>
            <Link href="/admin/schedule" className="text-sm font-medium text-primary">
              Schedule →
            </Link>
          </div>
          {upcoming.length === 0 ? (
            <p className="py-6 text-center text-sm text-muted">Nothing scheduled.</p>
          ) : (
            <ul className="divide-y divide-border">
              {upcoming.map((session) => (
                <li key={session.id} className="flex items-center justify-between gap-3 py-3">
                  <div className="min-w-0">
                    <p className="truncate text-sm font-medium text-navy">{session.title}</p>
                    <p className="text-xs text-muted">
                      {session.subject} · {session.teacher} · {formatWhen(session.startsAt)}
                    </p>
                  </div>
                  <Pill status={session.status} />
                </li>
              ))}
            </ul>
          )}
        </Card>

        <Card>
          <div className="mb-4 flex items-center justify-between">
            <h2 className="font-semibold text-navy">Recent notifications</h2>
            <Link href="/admin/notifications" className="text-sm font-medium text-primary">
              Send one →
            </Link>
          </div>
          <ul className="divide-y divide-border">
            {notifications.map((item) => (
              <li key={item.id} className="py-3">
                <p className="text-sm font-medium text-navy">{item.title}</p>
                <p className="mt-0.5 line-clamp-1 text-xs text-muted">{item.body}</p>
                <p className="mt-1 text-xs text-muted">
                  {describeAudience(item.audienceKind, item.audienceValue)} ·{" "}
                  {formatWhen(item.sentAt)}
                </p>
              </li>
            ))}
          </ul>
        </Card>
      </div>

      <Card className="mt-4">
        <div className="mb-4 flex items-center justify-between">
          <h2 className="font-semibold text-navy">Tickets needing a reply</h2>
          <Link href="/admin/tickets" className="text-sm font-medium text-primary">
            All tickets →
          </Link>
        </div>
        {openTickets.length === 0 ? (
          <p className="py-6 text-center text-sm text-muted">Nothing waiting. Nice.</p>
        ) : (
          <ul className="divide-y divide-border">
            {openTickets.map((ticket) => (
              <li key={ticket.id} className="flex items-center justify-between gap-3 py-3">
                <div className="min-w-0">
                  <Link
                    href={`/admin/tickets/${ticket.id}`}
                    className="truncate text-sm font-medium text-navy hover:text-primary"
                  >
                    {ticket.subject}
                  </Link>
                  <p className="text-xs text-muted">
                    {ticket.reference} · {ticket.studentName} · {ticket.category}
                  </p>
                </div>
                <Pill status={ticket.status} />
              </li>
            ))}
          </ul>
        )}
      </Card>
    </>
  );
}
