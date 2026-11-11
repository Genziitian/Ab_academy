import Link from "next/link";
import { Eyebrow } from "@/components/ui";
import { getT } from "@/lib/i18n/server";
import { CONTACT } from "@/lib/landing";
import { ContactForm } from "./ContactForm";

export const metadata = {
  title: "Contact",
  description: "Contact AB Academy support.",
};

export default async function ContactPage() {
  const { t } = await getT();
  const c = t.contact;
  const rows = [
    [c.email, CONTACT.email],
    [c.replyTime, c.replyValue],
    [c.address, CONTACT.address.join(", ")],
  ];
  return (
    <section className="mx-auto grid max-w-[1280px] gap-12 px-4 pb-20 pt-14 sm:px-6 lg:grid-cols-2 lg:gap-16 lg:px-10 lg:pt-20">
      <div>
        <Eyebrow>{c.eyebrow}</Eyebrow>
        <h1 className="ab-display mt-4 text-[38px] sm:text-[52px]">{c.title}</h1>
        <p className="mt-4 max-w-[460px] text-[17px] leading-[1.6] text-ab-ink-2">{c.lead}</p>
        <dl className="mt-10 overflow-hidden rounded-2xl border border-ab-rule bg-ab-panel">
          {rows.map(([label, value]) => (
            <div key={label} className="flex flex-wrap justify-between gap-x-4 gap-y-1 border-b border-ab-rule px-5 py-4 last:border-b-0">
              <dt className="text-sm text-ab-ink-3">{label}</dt>
              <dd className="text-[15px] font-medium text-ab-ink">{value}</dd>
            </div>
          ))}
        </dl>
        <p className="mt-5 text-sm text-ab-ink-2">
          {c.enrolled}{" "}
          <Link href="/support" className="font-medium text-ab-ink underline decoration-ab-rule-strong underline-offset-4 hover:decoration-ab-ink">
            {c.raiseTicket}
          </Link>{" "}
          {c.fromPortal}
        </p>
      </div>
      <ContactForm />
    </section>
  );
}
