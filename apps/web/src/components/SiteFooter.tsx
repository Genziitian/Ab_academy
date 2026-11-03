import Link from "next/link";
import { PlayBadge } from "@/components/landing/PlayBadge";
import { LEGAL_DOCS } from "@/components/LegalPage";
import { CONTACT, TEACHER } from "@/lib/landing";

const columns = [
  {
    title: "Crash courses",
    links: [
      { href: "/#courses", label: "Physics" },
      { href: "/#courses", label: "Chemistry" },
      { href: "/#courses", label: "Maths" },
      { href: "/notes", label: "Free notes" },
    ],
  },
  {
    title: "Academy",
    links: [
      { href: "/#about", label: "About us" },
      { href: "/#faq", label: "FAQ" },
      { href: "/login", label: "Student login" },
      { href: "/contact", label: "Help & support" },
    ],
  },
];

export function SiteFooter() {
  return (
    <footer className="mt-auto bg-coal text-mist">
      <div className="mx-auto grid max-w-[1280px] gap-10 px-4 pb-8 pt-16 sm:px-6 md:grid-cols-2 lg:grid-cols-[1.5fr_1fr_1fr_1.3fr] lg:gap-12 lg:px-16 lg:pt-[72px]">
        <div>
          <p className="font-serif text-4xl leading-none text-cream">AB Academy</p>
          <p className="mt-1.5 text-[13px] text-[#9a8f82]">Akhand Bharat Academy</p>
          <p className="mt-4 max-w-[300px] text-[15px] leading-[1.6]">
            Class 12 crash courses for Bihar Board. Recorded classes and live doubt sessions with{" "}
            {TEACHER.name}.
          </p>
          <PlayBadge tone="light" className="mt-5 w-fit" />
        </div>

        {columns.map((column) => (
          <div key={column.title} className="flex flex-col gap-3 text-[15px]">
            <p className="mb-1 text-xs font-bold uppercase tracking-[0.14em] text-saffron">{column.title}</p>
            {column.links.map((link) => (
              <Link key={link.label} href={link.href} className="text-mist hover:text-cream">
                {link.label}
              </Link>
            ))}
          </div>
        ))}

        <div className="flex flex-col gap-3 text-[15px] leading-[1.5]">
          <p className="mb-1 text-xs font-bold uppercase tracking-[0.14em] text-saffron">Visit &amp; support</p>
          <address className="not-italic">
            {CONTACT.address.map((line) => (
              <span key={line} className="block">
                {line}
              </span>
            ))}
          </address>
          <a href={`mailto:${CONTACT.email}`} className="font-semibold text-cream hover:text-saffron">
            {CONTACT.email}
          </a>
          <span className="font-semibold text-cream">{CONTACT.site}</span>
        </div>
      </div>
      <div className="mx-auto flex max-w-[1280px] flex-col gap-3 border-t border-coal-line px-4 py-5 text-[13px] text-[#9a8f82] sm:flex-row sm:justify-between sm:px-6 lg:px-16">
        <span>
          © {new Date().getFullYear()} AB Academy · {CONTACT.site}
        </span>
        <div className="flex flex-wrap gap-x-5 gap-y-2">
          {LEGAL_DOCS.map((doc) => (
            <Link key={doc.href} href={doc.href} className="hover:text-cream">
              {doc.label}
            </Link>
          ))}
        </div>
      </div>
    </footer>
  );
}
