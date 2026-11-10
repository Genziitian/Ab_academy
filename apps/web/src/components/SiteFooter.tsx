import Link from "next/link";
import { PlayBadge } from "@/components/landing/PlayBadge";
import { LEGAL_DOCS } from "@/components/LegalPage";
import {
  BrandMark,
  Wordmark,
  InstagramIcon,
  LinkedInIcon,
  WhatsAppIcon,
  YouTubeIcon,
} from "@/components/icons";
import { CONTACT, NOTES_LIVE, SOCIAL_LINKS, TEACHER } from "@/lib/landing";
import { helpHref, helpIsWhatsApp } from "@/lib/support";

const socials = [
  { href: SOCIAL_LINKS.youtube, label: "YouTube", Icon: YouTubeIcon },
  { href: SOCIAL_LINKS.instagram, label: "Instagram", Icon: InstagramIcon },
  {
    href: SOCIAL_LINKS.whatsapp || (helpIsWhatsApp ? helpHref : ""),
    label: "WhatsApp",
    Icon: WhatsAppIcon,
  },
  { href: SOCIAL_LINKS.linkedin, label: "LinkedIn", Icon: LinkedInIcon },
].filter((s) => s.href);

const columns = [
  {
    title: "Crash courses",
    links: [
      { href: "/#courses", label: "Physics" },
      { href: "/#courses", label: "Chemistry" },
      { href: "/#courses", label: "Maths" },
      { href: "/notes", label: NOTES_LIVE ? "Notes" : "Notes (coming soon)" },
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
          <div className="flex items-center gap-3">
            <BrandMark size={56} />
            <Wordmark size="lg" tone="light" />
          </div>
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
      <div className="mx-auto max-w-[1280px] px-4 sm:px-6 lg:px-16">
        <div className="grid items-center gap-6 border-t border-coal-line py-8 text-[15px] lg:grid-cols-[1fr_auto_1fr]">
          <nav aria-label="Legal" className="flex flex-wrap gap-x-6 gap-y-2 font-semibold text-dust">
            {LEGAL_DOCS.map((doc) => (
              <Link key={doc.href} href={doc.href} className="hover:text-cream">
                {doc.label}
              </Link>
            ))}
          </nav>
          {socials.length ? (
            <div className="flex gap-4 lg:justify-center">
              {socials.map(({ href, label, Icon }) => (
                <a
                  key={label}
                  href={href}
                  target="_blank"
                  rel="noopener noreferrer"
                  aria-label={label}
                  className="flex size-12 items-center justify-center rounded-full border border-coal-line text-dust hover:border-saffron hover:text-saffron"
                >
                  <Icon size={20} />
                </a>
              ))}
            </div>
          ) : (
            <span />
          )}
          <p className="font-semibold text-dust lg:text-right">
            © {new Date().getFullYear()} AB Academy. All rights reserved.
          </p>
        </div>
      </div>
      <p className="mx-auto max-w-[1200px] px-4 pb-6 text-xs leading-relaxed text-dust sm:px-6 lg:px-16">
        AB Academy is a private coaching institute and is not affiliated with, endorsed by or
        representing the Bihar School Examination Board (BSEB) or any government body. For the
        official syllabus, exam dates and results, visit{" "}
        <a
          href="https://biharboardonline.bihar.gov.in"
          target="_blank"
          rel="noopener noreferrer"
          className="underline hover:text-saffron"
        >
          biharboardonline.bihar.gov.in
        </a>
        .
      </p>
      {/* Oversized wordmark, barely lighter than the footer. */}
      <p
        aria-hidden
        className="select-none overflow-hidden whitespace-nowrap px-4 pb-6 text-center text-[13.5vw] font-bold uppercase leading-[0.8] tracking-[-0.04em] text-transparent sm:px-6 lg:px-16 xl:text-[180px]"
        style={{
          backgroundImage: "linear-gradient(180deg, rgba(247,243,236,0.07), rgba(247,243,236,0.02))",
          WebkitBackgroundClip: "text",
          backgroundClip: "text",
        }}
      >
        AB Academy
      </p>
    </footer>
  );
}
