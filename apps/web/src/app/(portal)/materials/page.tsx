import Link from "next/link";
import { PdfBadge } from "@/components/PdfBadge";
import { PortalTopbar } from "@/components/portal/PortalTopbar";
import { Arrow } from "@/components/ui";
import { subjectName } from "@/lib/i18n/content";
import { getT } from "@/lib/i18n/server";
import { getFreeNotes } from "@/lib/notes";

export const metadata = { title: "Notes" };

export default async function NotesPage() {
  const [all, { t, locale }] = await Promise.all([getFreeNotes(), getT()]);
  const p = t.portal;
  const library = all.map((s) => ({ ...s, chapters: s.chapters.filter((c) => c.notes.length) })).filter((s) => s.chapters.length);

  return (
    <>
      <PortalTopbar title={p.notes} lead={p.notesLead} />
      <div className="px-4 pb-16 pt-5 sm:px-8">
        {library.length ? (
          <div className="grid gap-4 lg:grid-cols-3">
            {library.map((s) => (
              <section key={s.id} className="rounded-[20px] bg-ab-tray p-1.5">
                <h2 className="px-3 pb-2 pt-1.5 text-sm text-ab-ink-2">{subjectName(s.name, locale)}</h2>
                <ul className="overflow-hidden rounded-[14px] border border-ab-rule bg-ab-panel">
                  {s.chapters.flatMap((c) =>
                    c.notes.map((n) => (
                      <li key={n.id} className="border-b border-ab-rule last:border-b-0">
                        <Link href={`/notes/free/${n.id}`} className="flex items-center gap-3 px-4 py-3 hover:bg-ab-canvas">
                          <PdfBadge size={28} />
                          <span className="min-w-0 flex-1">
                            <span className="block truncate text-[15px] font-medium text-ab-ink">{n.title}</span>
                            <span className="block truncate text-xs text-ab-ink-3">{c.title}</span>
                          </span>
                          <Arrow className="text-ab-ink-3" />
                        </Link>
                      </li>
                    )),
                  )}
                </ul>
              </section>
            ))}
          </div>
        ) : (
          <div className="rounded-2xl border border-dashed border-ab-rule-strong px-6 py-12 text-center">
            <p className="ab-title text-2xl">{p.notesEmptyTitle}</p>
            <p className="mx-auto mt-2 max-w-[440px] text-[15px] text-ab-ink-2">{p.notesEmptyBody}</p>
          </div>
        )}
      </div>
    </>
  );
}
