import { Card, EmptyRow, PageHeader, Pill } from "@/components/admin/AdminChrome";
import { isDemoMode, requireSuperAdmin } from "@/lib/admin/auth";
import { formatWhen } from "@/lib/admin/format";
import { createServerClient } from "@/lib/supabase/server";
import { processDeletion } from "./actions";

export const metadata = { title: "Deletion requests" };

type Row = {
  id: string;
  kind: "data" | "account";
  status: "pending" | "completed" | "rejected" | "cancelled";
  reason: string | null;
  contact: string | null;
  student_code: string | null;
  requested_at: string;
  due_at: string;
  processed_at: string | null;
  admin_note: string | null;
};

async function listRequests(): Promise<Row[]> {
  if (isDemoMode()) return [];
  const supabase = await createServerClient();
  if (!supabase) return [];
  const { data } = await supabase
    .from("deletion_requests")
    .select("id, kind, status, reason, contact, student_code, requested_at, due_at, processed_at, admin_note")
    .order("requested_at", { ascending: false })
    .limit(200);
  return (data ?? []) as Row[];
}

function timeLeft(due: string) {
  const ms = new Date(due).getTime() - Date.now();
  if (ms <= 0) return { label: "Overdue", overdue: true };
  const hours = Math.floor(ms / 36e5);
  return { label: hours >= 24 ? `${Math.floor(hours / 24)}d ${hours % 24}h left` : `${hours}h left`, overdue: false };
}

export default async function DeletionsPage() {
  await requireSuperAdmin();
  const rows = await listRequests();
  const pending = rows.filter((r) => r.status === "pending");
  const done = rows.filter((r) => r.status !== "pending");

  return (
    <>
      <PageHeader
        title="Deletion requests"
        description="Students asking to erase their data or close their account. Google Play requires these to be honoured — complete each within 3 days."
      />

      <Card className="mb-6">
        <h2 className="mb-3 text-base font-semibold text-navy">Waiting ({pending.length})</h2>
        {pending.length ? (
          <ul className="divide-y divide-border">
            {pending.map((r) => {
              const left = timeLeft(r.due_at);
              return (
                <li key={r.id} className="flex flex-col gap-3 py-4 lg:flex-row lg:items-start lg:justify-between">
                  <div className="min-w-0">
                    <p className="font-semibold text-navy">
                      {r.kind === "account" ? "Delete account" : "Delete data"} · {r.contact ?? "—"}
                      {r.student_code ? <span className="ml-2 text-sm font-normal text-muted">{r.student_code}</span> : null}
                    </p>
                    <p className="mt-1 text-sm text-muted">
                      Requested {formatWhen(r.requested_at)} ·{" "}
                      <span className={left.overdue ? "font-semibold text-danger" : "font-semibold text-navy"}>
                        {left.label}
                      </span>
                    </p>
                    {r.reason ? <p className="mt-2 text-sm text-ink">“{r.reason}”</p> : null}
                    <p className="mt-2 text-xs text-muted">
                      {r.kind === "account"
                        ? "Approving erases their data, then deletes the sign-in, profile and enrolments. Orders are kept without their name."
                        : "Approving erases name, school, doubts, comments, tickets and history. The account and courses stay."}
                    </p>
                  </div>
                  <form action={processDeletion} className="flex shrink-0 flex-col gap-2 sm:flex-row sm:items-center">
                    <input type="hidden" name="id" value={r.id} />
                    <input
                      name="note"
                      placeholder="Note (optional)"
                      aria-label="Note"
                      className="rounded-xl border border-border bg-surface px-3 py-2 text-sm text-navy outline-none focus:border-primary"
                    />
                    <button
                      name="decision"
                      value="reject"
                      className="rounded-full border border-border px-4 py-2 text-sm font-semibold text-ink hover:bg-surface-soft"
                    >
                      Reject
                    </button>
                    <button
                      name="decision"
                      value="approve"
                      className="rounded-full bg-danger px-4 py-2 text-sm font-semibold text-white hover:opacity-90"
                    >
                      {r.kind === "account" ? "Approve & delete account" : "Approve & erase data"}
                    </button>
                  </form>
                </li>
              );
            })}
          </ul>
        ) : (
          <EmptyRow>No requests waiting.</EmptyRow>
        )}
      </Card>

      <Card>
        <h2 className="mb-3 text-base font-semibold text-navy">History</h2>
        {done.length ? (
          <ul className="divide-y divide-border text-sm">
            {done.map((r) => (
              <li key={r.id} className="flex flex-wrap items-center justify-between gap-3 py-3">
                <span>
                  <span className="font-semibold text-navy">
                    {r.kind === "account" ? "Delete account" : "Delete data"} · {r.contact ?? "—"}
                  </span>
                  <span className="block text-muted">
                    Requested {formatWhen(r.requested_at)}
                    {r.processed_at ? ` · closed ${formatWhen(r.processed_at)}` : ""}
                    {r.admin_note ? ` · ${r.admin_note}` : ""}
                  </span>
                </span>
                <Pill status={r.status === "completed" ? "resolved" : r.status === "rejected" ? "closed" : "draft"} label={r.status} />
              </li>
            ))}
          </ul>
        ) : (
          <EmptyRow>Nothing yet.</EmptyRow>
        )}
      </Card>
    </>
  );
}
