import Image from "next/image";
import Link from "next/link";
import { PdfBadge } from "@/components/PdfBadge";
import { NOTES_LIVE, SYLLABUS, type SubjectKey } from "@/lib/landing";
import { createServerClient } from "@/lib/supabase/server";

export const metadata = {
  title: "Notes",
  description: "Chapter notes and solved PYQs for Bihar Board Class 12 Physics, Chemistry and Maths.",
};

const SUBJECTS = Object.keys(SYLLABUS) as SubjectKey[];

type NoteRow = {
  id: string;
  title: string;
  lessons: { chapters: { subjects: { name: string } | null } | null } | null;
};

/** Notes the visitor may open, grouped by subject. RLS decides which. */
async function listNotes() {
  const supabase = await createServerClient();
  if (!supabase) return [];
  const { data } = await supabase
    .from("lesson_resources")
    .select("id, title, lessons ( chapters ( subjects ( name ) ) )")
    .order("created_at", { ascending: false })
    .limit(200);
  return ((data ?? []) as unknown as NoteRow[]).map((r) => ({
    id: r.id,
    title: r.title,
    subject: r.lessons?.chapters?.subjects?.name ?? "Notes",
  }));
}

export default async function NotesPage() {
  const notes = NOTES_LIVE ? await listNotes() : [];

  return (
    <>
      <section className="mx-auto grid max-w-[1280px] items-center gap-10 px-4 pb-14 pt-10 sm:px-6 lg:grid-cols-[1.1fr_1fr] lg:gap-14 lg:px-16 lg:py-[72px]">
        <div>
          <p className="kicker text-clay">Free notes</p>
          <h1 className="mt-3 font-serif text-[52px] leading-[0.95] tracking-[-0.02em] text-balance sm:text-[84px]">
            {NOTES_LIVE ? "Read before you pay." : "Notes are coming soon."}
          </h1>
          <p className="mt-5 max-w-[520px] text-lg leading-[1.6] text-taupe">
            A notes PDF and solved PYQs for every Class 12 chapter, in Hindi and English. They open in a secure
            viewer on the website and in the app — sign in once and read anywhere.
          </p>
          {!NOTES_LIVE ? (
            <div className="mt-8 flex flex-col gap-3 sm:flex-row">
              <Link
                href="/#courses"
                className="flex h-[52px] items-center justify-center rounded-full bg-saffron px-7 text-base font-bold text-coal hover:bg-coal hover:text-cream"
              >
                Join Class 12 Crash Course
              </Link>
              <Link
                href="/login"
                className="flex h-[52px] items-center justify-center rounded-full border border-coal px-7 text-base font-semibold text-coal hover:bg-coal hover:text-cream"
              >
                Sign in to get notified
              </Link>
            </div>
          ) : null}
        </div>
        <div className="relative aspect-[1260/714] overflow-hidden rounded-3xl">
          <Image
            src="/images/brand/banner-notes.png"
            alt="Free notes and solved PYQs"
            fill
            priority
            sizes="(min-width: 1024px) 560px, 100vw"
            className="object-cover"
          />
        </div>
      </section>

      <section className="border-t border-sand bg-paper">
        <div className="mx-auto max-w-[1280px] px-4 py-16 sm:px-6 lg:px-16 lg:py-20">
          {NOTES_LIVE && notes.length ? (
            <div className="grid gap-10 lg:grid-cols-3">
              {[...new Set(notes.map((n) => n.subject))].map((subject) => (
                <div key={subject}>
                  <h2 className="font-serif text-4xl">{subject}</h2>
                  <ul className="mt-4 border-t-2 border-coal">
                    {notes
                      .filter((n) => n.subject === subject)
                      .map((n) => (
                        <li key={n.id} className="border-b border-sand">
                          <Link href={`/notes/${n.id}`} className="flex items-center gap-3 py-4 hover:text-clay">
                            <PdfBadge size={36} />
                            <span className="flex-1 font-semibold">{n.title}</span>
                            <span className="text-sm font-semibold">Read →</span>
                          </Link>
                        </li>
                      ))}
                  </ul>
                </div>
              ))}
            </div>
          ) : (
            <div className="grid gap-10 lg:grid-cols-3">
              {SUBJECTS.map((subject) => (
                <div key={subject}>
                  <div className="flex items-baseline justify-between gap-4">
                    <h2 className="font-serif text-4xl">{subject}</h2>
                    <span className="rounded-full bg-primary-soft px-3 py-1 text-xs font-bold uppercase tracking-[0.12em] text-clay">
                      Coming soon
                    </span>
                  </div>
                  <ol className="mt-4 border-t-2 border-coal">
                    {SYLLABUS[subject].map((chapter, i) => (
                      <li key={chapter} className="flex gap-3 border-b border-sand py-3 text-[15px] text-taupe">
                        <span className="w-6 shrink-0 font-semibold tabular-nums text-coal">{i + 1}.</span>
                        {chapter}
                      </li>
                    ))}
                  </ol>
                </div>
              ))}
            </div>
          )}
        </div>
      </section>
    </>
  );
}
