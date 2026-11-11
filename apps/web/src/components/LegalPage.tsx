import Link from "next/link";
import { formatDate, type Locale } from "@/lib/i18n/config";
import type { Dict } from "@/lib/i18n/dictionaries";
import { LEGAL_DOCS, type LegalHref } from "@/lib/legal-docs";
import { HINDI_LEGAL_NOTE, LEGAL_UPDATED, type LegalDoc } from "@/lib/i18n/legal";

/** Shared shell for the legal pages: the document list on the left, text on the right. */
export function LegalPage({
  active,
  doc,
  t,
  locale,
  children,
}: {
  active: LegalHref;
  doc: LegalDoc;
  t: Dict;
  locale: Locale;
  children?: React.ReactNode;
}) {
  return (
    <div className="mx-auto grid max-w-[1200px] gap-10 px-4 pb-24 pt-12 sm:px-6 sm:pt-16 md:grid-cols-[220px_minmax(0,700px)] md:gap-16">
      <nav aria-label={t.nav.legal} className="flex flex-col gap-0.5 self-start md:sticky md:top-28">
        <p className="ab-eyebrow mb-3 px-3">{t.nav.legal}</p>
        {LEGAL_DOCS.map((d) => {
          const on = active === d.href;
          return (
            <Link
              key={d.href}
              href={d.href}
              aria-current={on ? "page" : undefined}
              className={`flex items-center gap-2.5 rounded-[10px] px-3 py-2.5 text-[15px] ${
                on ? "bg-ab-panel font-medium text-ab-ink shadow-[0_0_0_1px_var(--color-ab-rule)]" : "text-ab-ink-2 hover:text-ab-ink"
              }`}
            >
              <span className={`size-1.5 rounded-full ${on ? "bg-ab-accent" : "bg-transparent"}`} />
              {t.legalDocs[d.key]}
            </Link>
          );
        })}
      </nav>
      <article>
        <h1 className="ab-display text-[38px] sm:text-[52px]">{doc.title}</h1>
        <p className="ab-num mt-3 text-[13px] text-ab-ink-3">{t.legalDocs.updated(formatDate(LEGAL_UPDATED, locale, { day: "numeric", month: "long", year: "numeric" }))}</p>
        {locale === "hi" ? (
          <p className="mt-5 rounded-xl border border-ab-rule bg-ab-panel px-4 py-3 text-sm text-ab-ink-2">{HINDI_LEGAL_NOTE}</p>
        ) : null}
        <p className="mt-6 text-lg leading-[1.65] text-ab-ink-2">{doc.intro}</p>
        {children ? <div className="mt-8">{children}</div> : null}
        <div className="mt-10 flex flex-col gap-10 border-t border-ab-rule pt-10">
          {doc.sections.map((section, i) => (
            <section key={section.heading ?? i} className="grid gap-3.5 sm:grid-cols-[40px_1fr]">
              <span className="ab-num pt-1 text-[13px] text-ab-ink-3">{String(i + 1).padStart(2, "0")}</span>
              <div className="flex flex-col gap-3.5">
                {section.heading ? <h2 className="ab-title text-xl text-ab-ink">{section.heading}</h2> : null}
                {section.body.map((block, j) =>
                  Array.isArray(block) ? (
                    <ul key={j} className="flex flex-col gap-2.5">
                      {block.map((item) => (
                        <li key={item} className="flex gap-3 text-base leading-[1.7] text-ab-ink-2">
                          <span className="mt-[11px] h-px w-3 shrink-0 bg-ab-ink-3" />
                          {item}
                        </li>
                      ))}
                    </ul>
                  ) : (
                    <p key={j} className="text-base leading-[1.75] text-ab-ink-2">
                      {block}
                    </p>
                  ),
                )}
              </div>
            </section>
          ))}
        </div>
      </article>
    </div>
  );
}
