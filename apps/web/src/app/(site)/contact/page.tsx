import Link from "next/link";
import { ContactForm } from "./ContactForm";

export const metadata = {
  title: "Contact",
  description: "Contact Akhand Bharat Academy support.",
};

const rows = [
  ["Email", "support@akhandbharatacademy.in"],
  ["WhatsApp", "+91 90000 00000 (placeholder)"],
  ["Hours", "Mon–Sat, 9:00 AM – 7:00 PM IST"],
];

export default function ContactPage() {
  return (
    <section className="mx-auto grid max-w-[1200px] gap-16 px-4 pb-[88px] pt-14 sm:px-6 sm:pt-[72px] lg:grid-cols-2">
      <div>
        <p className="eyebrow">Contact</p>
        <h1 className="mt-3 text-[36px] font-bold leading-[1.1] tracking-[-0.025em] text-navy sm:text-[46px]">
          We&apos;re here to help
        </h1>
        <p className="mt-4 max-w-[460px] text-[17px] leading-[1.6] text-ink">
          Questions about courses, payments or live classes? Reach the support
          team.
        </p>
        <div className="mt-9 rounded-xl border border-border bg-white">
          {rows.map(([label, value], index) => (
            <div
              key={label}
              className={`flex flex-wrap justify-between gap-x-4 gap-y-1 px-[22px] py-[18px] ${
                index < rows.length - 1 ? "border-b border-border" : ""
              }`}
            >
              <span className="text-sm text-muted">{label}</span>
              <span className="text-[15px] font-semibold text-navy">{value}</span>
            </div>
          ))}
        </div>
        <p className="mt-5 text-sm text-muted">
          Already enrolled?{" "}
          <Link href="/support" className="font-semibold text-primary">
            Raise a support ticket
          </Link>{" "}
          from your portal.
        </p>
      </div>
      <ContactForm />
    </section>
  );
}
