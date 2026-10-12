import Link from "next/link";

const docs = [
  { href: "/privacy", label: "Privacy Policy" },
  { href: "/terms", label: "Terms of Service" },
];

/** Shared two-column shell for the privacy and terms pages. */
export function LegalPage({
  active,
  title,
  paragraphs,
}: {
  active: "/privacy" | "/terms";
  title: string;
  paragraphs: string[];
}) {
  return (
    <div className="mx-auto grid max-w-[1200px] gap-10 px-4 pb-24 pt-14 sm:px-6 sm:pt-16 md:grid-cols-[220px_minmax(0,720px)] md:gap-16">
      <nav className="flex flex-col gap-0.5 self-start md:sticky md:top-24">
        <p className="mb-2.5 text-[11px] font-semibold uppercase tracking-[0.08em] text-muted">
          Legal
        </p>
        {docs.map((doc) => (
          <Link
            key={doc.href}
            href={doc.href}
            className={`rounded-md px-3 py-2 text-sm ${
              active === doc.href
                ? "bg-primary-soft font-semibold text-primary"
                : "font-medium text-ink hover:text-navy"
            }`}
          >
            {doc.label}
          </Link>
        ))}
        <Link
          href="/contact"
          className="mt-1.5 px-3 py-2 text-sm font-medium text-ink hover:text-navy"
        >
          Refund / Grievance
        </Link>
      </nav>
      <article>
        <h1 className="text-[32px] font-bold tracking-[-0.02em] text-navy sm:text-[40px]">
          {title}
        </h1>
        <p className="mt-2.5 text-sm text-muted">Draft · Last updated October 2026</p>
        <div className="mt-8 flex flex-col gap-[18px] border-t border-border pt-8">
          {paragraphs.map((p) => (
            <p key={p} className="text-base leading-[1.75] text-ink">
              {p}
            </p>
          ))}
        </div>
      </article>
    </div>
  );
}
