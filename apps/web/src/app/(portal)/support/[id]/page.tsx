import Link from "next/link";
import { notFound } from "next/navigation";
import { PortalTopbar } from "@/components/portal/PortalTopbar";
import { createServerClient } from "@/lib/supabase/server";
import { replyTicketAction } from "../actions";

export const metadata = { title: "Ticket" };

export default async function TicketPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
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
      <PortalTopbar crumb={<Link href="/support" className="hover:underline">← Help &amp; support · {ticket.reference}</Link>} title={ticket.subject} />
      <div className="max-w-[820px] px-4 pb-16 pt-6 sm:px-8">
        <ul className="flex flex-col gap-3">
          {messages.map((m) => (
            <li
              key={m.id}
              className={`max-w-[85%] rounded-[20px] px-5 py-4 ${m.from_support ? "border border-sand bg-cream" : "ml-auto bg-coal text-cream"}`}
            >
              <p className={`text-xs font-bold uppercase tracking-[0.12em] ${m.from_support ? "text-clay" : "text-saffron"}`}>
                {m.from_support ? "AB Academy support" : "You"} ·{" "}
                {new Date(m.created_at).toLocaleString("en-IN", { day: "numeric", month: "short", hour: "numeric", minute: "2-digit", timeZone: "Asia/Kolkata" })}
              </p>
              <p className="mt-1.5 whitespace-pre-wrap text-[15px] leading-[1.55]">{m.body}</p>
            </li>
          ))}
        </ul>
        {open ? (
          <form action={replyTicketAction} className="mt-6 flex flex-col gap-3 sm:flex-row">
            <input type="hidden" name="ticketId" value={ticket.id} />
            <textarea
              name="body"
              required
              rows={2}
              placeholder="Write a reply…"
              className="min-h-12 flex-1 rounded-xl border border-sand bg-white px-3.5 py-2.5 text-[15px] outline-none focus:border-clay"
            />
            <button type="submit" className="h-12 rounded-full bg-clay px-6 text-[15px] font-semibold text-white hover:bg-coal">
              Send
            </button>
          </form>
        ) : (
          <p className="mt-6 text-sm text-taupe">This ticket is closed. Open a new one if you need more help.</p>
        )}
      </div>
    </>
  );
}
