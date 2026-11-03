import Link from "next/link";
import { PortalTopbar } from "@/components/portal/PortalTopbar";
import { CONTACT } from "@/lib/landing";
import { getMyTickets } from "@/lib/portal/live";
import { createTicketAction } from "./actions";

export const metadata = { title: "Help & support" };

const field =
  "mt-1.5 w-full rounded-xl border border-sand bg-white px-3.5 text-[15px] text-coal outline-none focus:border-clay focus:ring-2 focus:ring-clay/15";
const STATUS: Record<string, string> = {
  open: "bg-[#fff1df] text-[#8a4b0f]",
  in_progress: "bg-primary-soft text-clay",
  resolved: "bg-[#e9f6ee] text-[#1d6b3d]",
  closed: "bg-paper text-taupe",
};

export default async function SupportPage() {
  const tickets = await getMyTickets();
  return (
    <>
      <PortalTopbar crumb={`We reply within 2 working days · ${CONTACT.email}`} title="Help & support" />
      <div className="grid gap-6 px-4 pb-16 pt-6 sm:px-8 lg:grid-cols-[1fr_400px]">
        <section>
          <h2 className="font-serif text-[30px] leading-none text-coal">Your tickets</h2>
          {tickets.length ? (
            <ul className="mt-4 divide-y divide-sand overflow-hidden rounded-[22px] border border-sand bg-cream">
              {tickets.map((t) => (
                <li key={t.id}>
                  <Link href={`/support/${t.id}`} className="flex items-center gap-4 px-5 py-4 hover:bg-paper">
                    <span className="min-w-0 flex-1">
                      <span className="block truncate font-semibold text-coal">{t.subject}</span>
                      <span className="text-sm text-taupe">
                        {t.reference} · {new Date(t.updatedAt).toLocaleDateString("en-IN", { day: "numeric", month: "short" })}
                      </span>
                    </span>
                    <span className={`rounded-full px-3 py-1 text-xs font-bold capitalize ${STATUS[t.status] ?? STATUS.closed}`}>
                      {t.status.replace("_", " ")}
                    </span>
                  </Link>
                </li>
              ))}
            </ul>
          ) : (
            <p className="mt-4 rounded-[22px] border border-dashed border-sand bg-cream px-5 py-8 text-center text-taupe">
              No tickets yet. Ask anything about a course, a payment or your account.
            </p>
          )}
        </section>

        <form action={createTicketAction} className="h-fit space-y-4 rounded-[22px] border border-sand bg-cream p-5">
          <h2 className="font-serif text-[30px] leading-none text-coal">New ticket</h2>
          <label className="block text-[13px] font-semibold text-coal">
            Topic
            <select name="category" className={`${field} h-11`} defaultValue="content">
              <option value="content">Lectures or notes</option>
              <option value="payment">Payment or refund</option>
              <option value="technical">App or website problem</option>
              <option value="account">My account</option>
              <option value="other">Something else</option>
            </select>
          </label>
          <label className="block text-[13px] font-semibold text-coal">
            Subject
            <input name="subject" required maxLength={140} placeholder="Video not playing in Chapter 3" className={`${field} h-11`} />
          </label>
          <label className="block text-[13px] font-semibold text-coal">
            Message
            <textarea name="body" required rows={5} maxLength={4000} placeholder="Tell us what happened." className={`${field} py-2.5`} />
          </label>
          <button type="submit" className="h-12 w-full rounded-full bg-clay text-[15px] font-semibold text-white hover:bg-coal">
            Send ticket
          </button>
        </form>
      </div>
    </>
  );
}
