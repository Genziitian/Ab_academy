import Link from "next/link";
import { Card, EmptyRow, PageHeader, Pill } from "@/components/admin/AdminChrome";
import { formatWhen } from "@/lib/admin/format";
import { listTickets } from "@/lib/admin/data";

export default async function AdminTicketsPage({
  searchParams,
}: {
  searchParams: Promise<{ status?: string }>;
}) {
  const { status } = await searchParams;
  const all = await listTickets();
  const tickets = status && status !== "all" ? all.filter((t) => t.status === status) : all;

  const filters = [
    { value: "all", label: "All" },
    { value: "open", label: "Open" },
    { value: "in_progress", label: "In progress" },
    { value: "resolved", label: "Resolved" },
    { value: "closed", label: "Closed" },
  ];

  return (
    <>
      <PageHeader title="Tickets" description="Student support requests, newest first." />

      <div className="mb-4 flex flex-wrap gap-2">
        {filters.map((filter) => {
          const active = (status ?? "all") === filter.value;
          return (
            <Link
              key={filter.value}
              href={filter.value === "all" ? "/admin/tickets" : `/admin/tickets?status=${filter.value}`}
              className={`rounded-full px-3.5 py-1.5 text-sm transition-colors ${
                active
                  ? "bg-primary font-semibold text-white"
                  : "border border-border bg-surface text-muted hover:text-navy"
              }`}
            >
              {filter.label}
            </Link>
          );
        })}
      </div>

      <Card>
        {tickets.length === 0 ? (
          <EmptyRow>Nothing in this queue.</EmptyRow>
        ) : (
          <ul className="divide-y divide-border">
            {tickets.map((ticket) => (
              <li key={ticket.id} className="py-3.5">
                <div className="flex flex-wrap items-start justify-between gap-3">
                  <div className="min-w-0">
                    <Link
                      href={`/admin/tickets/${ticket.id}`}
                      className="font-medium text-navy hover:text-primary"
                    >
                      {ticket.subject}
                    </Link>
                    <p className="mt-1 text-xs text-muted">
                      {ticket.reference} · {ticket.studentName} · {ticket.category} ·{" "}
                      {formatWhen(ticket.openedAt)}
                    </p>
                    <p className="mt-1.5 line-clamp-1 text-sm text-muted">
                      {ticket.messages.at(-1)?.body}
                    </p>
                  </div>
                  <Pill status={ticket.status} />
                </div>
              </li>
            ))}
          </ul>
        )}
      </Card>
    </>
  );
}
