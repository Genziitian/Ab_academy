import Link from "next/link";
import { PlayBadge } from "@/components/landing/PlayBadge";
import { LEGAL_DOCS } from "@/lib/legal-docs";
import { BrandMark, InstagramIcon, LinkedInIcon, WhatsAppIcon, Wordmark, YouTubeIcon } from "@/components/icons";
import { getT } from "@/lib/i18n/server";
import { CONTACT, NOTES_LIVE, SOCIAL_LINKS } from "@/lib/landing";
import { helpHref, helpIsWhatsApp } from "@/lib/support";

const socials = [
  { href: SOCIAL_LINKS.youtube, label: "YouTube", Icon: YouTubeIcon },
  { href: SOCIAL_LINKS.instagram, label: "Instagram", Icon: InstagramIcon },
  { href: SOCIAL_LINKS.whatsapp || (helpIsWhatsApp ? helpHref : ""), label: "WhatsApp", Icon: WhatsAppIcon },
  { href: SOCIAL_LINKS.linkedin, label: "LinkedIn", Icon: LinkedInIcon },
].filter((s) => s.href);

export async function SiteFooter() {
  const { t } = await getT();
  const s = t.common.subjects;
  const columns = [
    {
      title: t.footer.coursesTitle,
      links: [
        { href: "/course/class-12-physics-crash-course", label: s.Physics },
        { href: "/course/class-12-chemistry-crash-course", label: s.Chemistry },
        { href: "/course/class-12-maths-crash-course", label: s.Maths },
        { href: "/notes", label: NOTES_LIVE ? t.nav.notes : `${t.nav.notes} · ${t.common.comingSoon}` },
      ],
    },
    {
      title: t.footer.academyTitle,
      links: [
        { href: "/about", label: t.footer.aboutUs },
        { href: "/#faq", label: t.nav.faq },
        { href: "/login", label: t.footer.studentLogin },
        { href: "/contact", label: t.nav.contact },
      ],
    },
  ];

  return (
    <footer className="mt-auto border-t border-ab-rule bg-ab-panel">
      <div className="mx-auto grid max-w-[1280px] gap-10 px-4 pb-10 pt-14 sm:px-6 md:grid-cols-2 lg:grid-cols-[1.4fr_1fr_1fr_1.2fr] lg:px-10">
        <div>
          <Link href="/" className="flex w-fit items-center gap-2.5">
            <BrandMark size={40} />
            <Wordmark />
          </Link>
          <p className="mt-5 max-w-[300px] text-[15px] leading-[1.6] text-ab-ink-2">{t.footer.tagline}</p>
          <PlayBadge className="mt-5 w-fit" />
        </div>

        {columns.map((column) => (
          <div key={column.title} className="flex flex-col gap-2.5 text-[15px]">
            <p className="ab-eyebrow mb-1.5">{column.title}</p>
            {column.links.map((link) => (
              <Link key={link.label} href={link.href} className="w-fit text-ab-ink-2 hover:text-ab-ink">
                {link.label}
              </Link>
            ))}
          </div>
        ))}

        <div className="flex flex-col gap-2.5 text-[15px] leading-[1.5]">
          <p className="ab-eyebrow mb-1.5">{t.footer.visitTitle}</p>
          <address className="not-italic text-ab-ink-2">
            {CONTACT.address.map((line) => (
              <span key={line} className="block">
                {line}
              </span>
            ))}
          </address>
          <a href={`mailto:${CONTACT.email}`} className="w-fit font-medium text-ab-ink underline decoration-ab-rule-strong underline-offset-4 hover:decoration-ab-ink">
            {CONTACT.email}
          </a>
        </div>
      </div>

      <div className="mx-auto max-w-[1280px] px-4 sm:px-6 lg:px-10">
        <div className="flex flex-col gap-5 border-t border-ab-rule py-6 text-sm lg:flex-row lg:items-center lg:justify-between">
          <nav aria-label={t.nav.legal} className="flex flex-wrap gap-x-5 gap-y-2 text-ab-ink-2">
            {LEGAL_DOCS.map((doc) => (
              <Link key={doc.href} href={doc.href} className="hover:text-ab-ink">
                {t.legalDocs[doc.key]}
              </Link>
            ))}
          </nav>
          {socials.length ? (
            <div className="flex gap-2">
              {socials.map(({ href, label, Icon }) => (
                <a
                  key={label}
                  href={href}
                  target="_blank"
                  rel="noopener noreferrer"
                  aria-label={label}
                  className="flex size-10 items-center justify-center rounded-full border border-ab-rule text-ab-ink-2 hover:border-ab-ink hover:text-ab-ink"
                >
                  <Icon size={18} />
                </a>
              ))}
            </div>
          ) : null}
          <p className="text-ab-ink-3">{t.footer.rights(new Date().getFullYear())}</p>
        </div>
        <p className="max-w-[900px] pb-8 text-xs leading-relaxed text-ab-ink-3">
          {t.footer.disclaimer}{" "}
          <a href="https://biharboardonline.bihar.gov.in" target="_blank" rel="noopener noreferrer" className="underline hover:text-ab-ink">
            biharboardonline.bihar.gov.in
          </a>
          .
        </p>
      </div>
    </footer>
  );
}
