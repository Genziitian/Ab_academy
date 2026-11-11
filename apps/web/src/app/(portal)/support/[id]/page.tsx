import Link from "next/link";
import { notFound } from "next/navigation";
import { PortalTopbar } from "@/components/portal/PortalTopbar";
import { btn } from "@/components/ui";
import { formatDateTime } from "@/lib/i18n/config";
import { getT } from "@/lib/i18n/server";
import { createServerClient } from "@/lib/supabase/server";
import { replyTicketAction } from "../actions";

export const metadata = { title: "Ticket" };

export default async function TicketPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const { t, locale } = await getT();
  const p = t.portal;
  const supabase = await createServerClient();
  if (!supabase) notFound();
  const { data: ticket } = await supabase
    .from("tickets")
    .select("id, reference, subject, status, ticket_messages ( id, body, from_support, created_at )")
    .eq("id", id)
    .maybeSingle();
  if (!ticket) notFound();
  const messages = [...((ticket.ticket_messages ?? []) as { id: string; body: string; from_support: boolean; created_at: string }[])].sort(
    (a, b) => a.created_at.localeCompare(b.created_at),
  );
  const open = ticket.status !== "closed";

  return (
    <>
      <PortalTopbar
        crumb={
          <Link href="/support" className="hover:text-ab-ink">
            ← {p.support} · <span className="ab-num">{ticket.reference}</span>
          </Link>
        }
        title={ticket.subject}
      />
      <div className="max-w-[820px] px-4 pb-16 pt-5 sm:px-8">
        <ul className="flex flex-col gap-3">
          {messages.map((m) => (
            <li
              key={m.id}
              className={`max-w-[85%] rounded-2xl px-5 py-4 ${m.from_support ? "border border-ab-rule bg-ab-canvas" : "ml-auto bg-ab-ink text-white"}`}
            >
              <p className={`text-xs ${m.from_support ? "text-ab-ink-3" : "text-white/55"}`}>
                {m.from_support ? p.supportName : p.you} · <span className="ab-num">{formatDateTime(m.created_at, locale)}</span>
              </p>
              <p className="mt-1.5 whitespace-pre-wrap text-[15px] leading-[1.6]">{m.body}</p>
            </li>
          ))}
        </ul>
        {open ? (
          <form action={replyTicketAction} className="mt-6 flex flex-col gap-3 sm:flex-row sm:items-end">
            <input type="hidden" name="ticketId" value={ticket.id} />
            <textarea
              name="body"
              required
              rows={2}
              placeholder={p.replyPh}
              className="min-h-12 flex-1 rounded-[10px] border border-ab-rule-strong bg-ab-panel px-3.5 py-2.5 text-[15px] outline-none focus:border-ab-ink"
            />
            <button type="submit" className={`${btn.primary} !h-12`}>
              {p.send}
            </button>
          </form>
        ) : (
          <p className="mt-6 text-sm text-ab-ink-3">{p.ticketClosed}</p>
        )}
      </div>
    </>
  );
}
