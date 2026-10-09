import Link from "next/link";
import { notFound } from "next/navigation";
import { Card, PageHeader, Pill } from "@/components/admin/AdminChrome";
import { formatWhen } from "@/lib/admin/format";
import { getTicket } from "@/lib/admin/data";
import { replyAction, setStatusAction } from "../actions";

export default async function AdminTicketDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  const ticket = await getTicket(id);
  if (!ticket) notFound();

  return (
    <>
      <Link href="/admin/tickets" className="mb-4 inline-block text-sm text-primary">
        ← All tickets
      </Link>

      <PageHeader
        title={ticket.subject}
        description={`${ticket.reference} · ${ticket.studentName} · ${ticket.category} · opened ${formatWhen(ticket.openedAt)}`}
        action={<Pill status={ticket.status} />}
      />

      <div className="grid gap-4 lg:grid-cols-[1.5fr_1fr]">
        <Card>
          <h2 className="mb-4 font-semibold text-navy">Conversation</h2>
          <ul className="space-y-4">
            {ticket.messages.map((message) => (
              <li
                key={message.id}
                className={`rounded-xl border p-3.5 ${
                  message.fromSupport
                    ? "border-primary-soft bg-primary-soft/40"
                    : "border-border bg-surface"
                }`}
              >
                <div className="flex items-center justify-between gap-3">
                  <p className="text-sm font-semibold text-navy">{message.authorName}</p>
                  <span className="text-xs text-muted">{formatWhen(message.at)}</span>
                </div>
                <p className="mt-1.5 text-sm leading-relaxed text-navy">{message.body}</p>
              </li>
            ))}
          </ul>

          <form action={replyAction} className="mt-5">
            <input type="hidden" name="ticketId" value={ticket.id} />
            <textarea
              name="body"
              required
              rows={4}
              placeholder="Write a reply to the student…"
              className="w-full resize-y rounded-xl border border-border bg-surface px-3 py-2 text-sm text-navy outline-none focus:border-primary"
            />
            <button
              type="submit"
              className="mt-3 rounded-xl bg-primary px-4 py-2.5 text-sm font-semibold text-white transition-colors hover:bg-primary-dark"
            >
              Send reply
            </button>
          </form>
        </Card>

        <Card>
          <h2 className="mb-3 font-semibold text-navy">Status</h2>
          <form action={setStatusAction} className="space-y-3">
            <input type="hidden" name="ticketId" value={ticket.id} />
            <select
              name="status"
              defaultValue={ticket.status}
              className="w-full rounded-xl border border-border bg-surface px-3 py-2 text-sm text-navy outline-none focus:border-primary"
            >
              <option value="open">Open</option>
              <option value="in_progress">In progress</option>
              <option value="resolved">Resolved</option>
              <option value="closed">Closed</option>
            </select>
            <button
              type="submit"
              className="w-full rounded-xl border border-border px-4 py-2.5 text-sm font-semibold text-navy transition-colors hover:border-primary hover:text-primary"
            >
              Update status
            </button>
          </form>
        </Card>
      </div>
    </>
  );
}
