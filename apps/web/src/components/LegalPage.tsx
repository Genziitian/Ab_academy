import Link from "next/link";

export const LEGAL_DOCS = [
  { href: "/privacy", label: "Privacy policy" },
  { href: "/terms", label: "Terms & conditions" },
  { href: "/refund", label: "Refund policy" },
  { href: "/data-deletion", label: "Data & account deletion" },
] as const;

export type LegalHref = (typeof LEGAL_DOCS)[number]["href"];

/** A paragraph is a string; a bulleted list is an array of strings. */
export type LegalSection = { heading?: string; body: (string | string[])[] };

export const LEGAL_UPDATED = "3 November 2026";

/** Shared shell for the legal pages: document list on the left, text on the right. */
export function LegalPage({
  active,
  title,
  intro,
  sections,
  children,
}: {
  active: LegalHref;
  title: string;
  intro?: string;
  sections: LegalSection[];
  children?: React.ReactNode;
}) {
  return (
    <div className="mx-auto grid max-w-[1200px] gap-10 px-4 pb-24 pt-12 sm:px-6 sm:pt-16 md:grid-cols-[230px_minmax(0,720px)] md:gap-16">
      <nav aria-label="Legal" className="flex flex-col gap-0.5 self-start md:sticky md:top-28">
        <p className="mb-2.5 text-[11px] font-bold uppercase tracking-[0.14em] text-muted">Legal</p>
        {LEGAL_DOCS.map((doc) => (
          <Link
            key={doc.href}
            href={doc.href}
            aria-current={active === doc.href ? "page" : undefined}
            className={`rounded-full px-4 py-2.5 text-[15px] ${
              active === doc.href ? "bg-primary-soft font-semibold text-primary" : "font-medium text-ink hover:text-navy"
            }`}
          >
            {doc.label}
          </Link>
        ))}
      </nav>
      <article>
        <h1 className="font-serif text-[44px] leading-none tracking-[-0.02em] text-navy sm:text-[60px]">{title}</h1>
        <p className="mt-3 text-sm text-muted">Last updated {LEGAL_UPDATED}</p>
        {intro ? <p className="mt-6 text-lg leading-[1.65] text-ink">{intro}</p> : null}
        {children ? <div className="mt-8">{children}</div> : null}
        <div className="mt-8 flex flex-col gap-9 border-t border-border pt-8">
          {sections.map((section, i) => (
            <section key={section.heading ?? i} className="flex flex-col gap-3.5">
              {section.heading ? (
                <h2 className="text-xl font-bold tracking-[-0.01em] text-navy">{section.heading}</h2>
              ) : null}
              {section.body.map((block, j) =>
                Array.isArray(block) ? (
                  <ul key={j} className="flex list-disc flex-col gap-2 pl-5 text-base leading-[1.7] text-ink">
                    {block.map((item) => (
                      <li key={item}>{item}</li>
                    ))}
                  </ul>
                ) : (
                  <p key={j} className="text-base leading-[1.75] text-ink">
                    {block}
                  </p>
                ),
              )}
            </section>
          ))}
        </div>
      </article>
    </div>
  );
}
