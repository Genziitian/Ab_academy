import Link from "next/link";
import { PortalTopbar } from "@/components/portal/PortalTopbar";
import { Arrow, Pill, btn, field, label } from "@/components/ui";
import { formatDate } from "@/lib/i18n/config";
import { getT } from "@/lib/i18n/server";
import { CONTACT } from "@/lib/landing";
import { getMyTickets } from "@/lib/portal/live";
import { createTicketAction } from "./actions";

export const metadata = { title: "Help & support" };

const TONE: Record<string, "accent" | "neutral" | "live"> = {
  open: "accent",
  in_progress: "accent",
  resolved: "live",
  closed: "neutral",
};

export default async function SupportPage() {
  const [tickets, { t, locale }] = await Promise.all([getMyTickets(), getT()]);
  const p = t.portal;
  return (
    <>
      <PortalTopbar title={p.support} lead={p.supportLead(CONTACT.email)} />
      <div className="grid gap-5 px-4 pb-16 pt-5 sm:px-8 lg:grid-cols-[1fr_400px]">
        <section>
          <h2 className="mb-3 text-sm text-ab-ink-2">{p.yourTickets}</h2>
          {tickets.length ? (
            <ul className="overflow-hidden rounded-2xl border border-ab-rule">
              {tickets.map((tk) => (
                <li key={tk.id} className="border-b border-ab-rule last:border-b-0">
                  <Link href={`/support/${tk.id}`} className="flex items-center gap-4 px-5 py-4 hover:bg-ab-canvas">
                    <span className="min-w-0 flex-1">
                      <span className="block truncate font-medium text-ab-ink">{tk.subject}</span>
                      <span className="ab-num text-[13px] text-ab-ink-3">
                        {tk.reference} · {formatDate(tk.updatedAt, locale, { day: "numeric", month: "short" })}
                      </span>
                    </span>
                    <Pill tone={TONE[tk.status] ?? "neutral"}>{p.status[tk.status] ?? tk.status}</Pill>
                    <Arrow className="hidden text-ab-ink-3 sm:block" />
                  </Link>
                </li>
              ))}
            </ul>
          ) : (
            <p className="rounded-2xl border border-dashed border-ab-rule-strong px-5 py-10 text-center text-[15px] text-ab-ink-2">{p.noTickets}</p>
          )}
        </section>

        <div className="h-fit rounded-[20px] bg-ab-tray p-1.5">
          <h2 className="px-3 pb-2 pt-1.5 text-sm text-ab-ink-2">{p.newTicket}</h2>
          <form action={createTicketAction} className="flex flex-col gap-4 rounded-[14px] border border-ab-rule bg-ab-panel p-5">
            <label className={label}>
              {p.topic}
              <select name="category" className={field} defaultValue="content">
                {Object.entries(p.topics).map(([value, text]) => (
                  <option key={value} value={value}>
                    {text}
                  </option>
                ))}
              </select>
            </label>
            <label className={label}>
              {p.subject}
              <input name="subject" required maxLength={140} placeholder={p.subjectPh} className={field} />
            </label>
            <label className={label}>
              {p.message}
              <textarea name="body" required rows={5} maxLength={4000} placeholder={p.messagePh} className={`${field} h-auto py-2.5`} />
            </label>
            <button type="submit" className={`${btn.primary} w-full`}>
              {p.sendTicket}
            </button>
          </form>
        </div>
      </div>
    </>
  );
}
