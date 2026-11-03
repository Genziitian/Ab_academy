import Link from "next/link";
import { PortalTopbar } from "@/components/portal/PortalTopbar";
import { getFreeNotes } from "@/lib/notes";

export const metadata = { title: "Notes" };

export default async function NotesPage() {
  const library = (await getFreeNotes())
    .map((s) => ({ ...s, chapters: s.chapters.filter((c) => c.notes.length) }))
    .filter((s) => s.chapters.length);

  return (
    <>
      <PortalTopbar crumb="Chapter notes and PYQs" title="Notes" />
      <div className="px-4 pb-16 pt-6 sm:px-8">
        {library.length ? (
          <div className="grid gap-5 lg:grid-cols-3">
            {library.map((s) => (
              <section key={s.id} className="rounded-[22px] border border-sand bg-cream p-5">
                <h2 className="font-serif text-[30px] leading-none text-coal">{s.name}</h2>
                <ul className="mt-4 flex flex-col gap-1">
                  {s.chapters.flatMap((c) =>
                    c.notes.map((n) => (
                      <li key={n.id}>
                        <Link href={`/notes/free/${n.id}`} className="flex justify-between gap-3 rounded-xl px-3 py-2 hover:bg-paper">
                          <span className="min-w-0">
                            <span className="block truncate font-medium text-coal">{n.title}</span>
                            <span className="text-xs text-taupe">{c.title}</span>
                          </span>
                          <span className="text-sm font-bold text-clay">Read</span>
                        </Link>
                      </li>
                    )),
                  )}
                </ul>
              </section>
            ))}
          </div>
        ) : (
          <div className="rounded-[24px] border border-dashed border-sand bg-cream px-6 py-12 text-center">
            <p className="font-serif text-[34px] leading-none text-coal">Notes are coming soon</p>
            <p className="mx-auto mt-3 max-w-[440px] text-taupe">
              Chapter notes and solved PYQs will appear here. Notes attached to a lecture open from that lecture.
            </p>
          </div>
        )}
      </div>
    </>
  );
}
