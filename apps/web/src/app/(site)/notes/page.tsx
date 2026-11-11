import Image from "next/image";
import Link from "next/link";
import { PdfBadge } from "@/components/PdfBadge";
import { Arrow, Eyebrow, Pill, btn } from "@/components/ui";
import { subjectName, syllabusFor } from "@/lib/i18n/content";
import { getT } from "@/lib/i18n/server";
import { NOTES_LIVE, type SubjectKey } from "@/lib/landing";
import { getFreeNotes } from "@/lib/notes";
import { createServerClient } from "@/lib/supabase/server";

export const metadata = {
  title: "Notes",
  description: "Chapter notes and solved PYQs for Bihar Board Class 12 Physics, Chemistry and Maths.",
};

const SUBJECTS: SubjectKey[] = ["Physics", "Chemistry", "Maths"];

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
  const { t, locale } = await getT();
  const n = t.notes;
  const notes = NOTES_LIVE ? await listNotes() : [];
  // The free library from Admin → Free notes; it switches the page on.
  const library = (await getFreeNotes())
    .map((s) => ({ ...s, chapters: s.chapters.filter((c) => c.notes.length) }))
    .filter((s) => s.chapters.length);
  const hasLibrary = library.length > 0;
  const syllabus = syllabusFor(locale);
  const row = "flex items-center gap-3 rounded-[10px] px-3 py-2.5 text-[15px] text-ab-ink hover:bg-ab-canvas";

  return (
    <>
      <section className="mx-auto grid max-w-[1280px] items-center gap-10 px-4 pb-14 pt-12 sm:px-6 lg:grid-cols-[1.1fr_1fr] lg:gap-14 lg:px-10 lg:py-20">
        <div>
          <Eyebrow>{n.eyebrow}</Eyebrow>
          <h1 className="ab-display mt-4 text-[40px] sm:text-[60px]">{hasLibrary || NOTES_LIVE ? n.titleLive : n.titleSoon}</h1>
          <p className="mt-5 max-w-[520px] text-[17px] leading-[1.6] text-ab-ink-2">{n.lead}</p>
          {!NOTES_LIVE && !hasLibrary ? (
            <div className="mt-8 flex flex-col gap-3 sm:flex-row">
              <Link href="/#courses" className={`${btn.primary} ${btn.lg}`}>
                {n.join}
              </Link>
              <Link href="/login" className={`${btn.secondary} ${btn.lg}`}>
                {n.notify}
              </Link>
            </div>
          ) : null}
        </div>
        <div className="relative aspect-[1260/714] overflow-hidden rounded-2xl bg-ab-tray">
          <Image src="/images/brand/banner-notes.png" alt={n.bannerAlt} fill priority sizes="(min-width: 1024px) 560px, 100vw" className="object-cover" />
        </div>
      </section>

      <section className="border-t border-ab-rule bg-ab-panel">
        <div className="mx-auto grid max-w-[1280px] gap-8 px-4 py-16 sm:px-6 lg:grid-cols-3 lg:px-10 lg:py-20">
          {hasLibrary
            ? library.map((subject) => (
                <div key={subject.id}>
                  <h2 className="ab-title border-b border-ab-ink pb-3 text-2xl">{subjectName(subject.name, locale)}</h2>
                  <ol className="mt-2">
                    {subject.chapters.map((chapter, i) => (
                      <li key={chapter.id} className="border-b border-ab-rule py-3">
                        <p className="flex gap-3 px-3 text-[15px] font-medium text-ab-ink">
                          <span className="ab-num w-6 shrink-0 text-[13px] text-ab-ink-3">{String(i + 1).padStart(2, "0")}</span>
                          {chapter.title}
                        </p>
                        <ul className="mt-1 pl-6">
                          {chapter.notes.map((note) => (
                            <li key={note.id}>
                              <Link href={`/notes/free/${note.id}`} className={row}>
                                <PdfBadge size={26} />
                                <span className="flex-1">{note.title}</span>
                                <Arrow className="text-ab-ink-3" />
                              </Link>
                            </li>
                          ))}
                        </ul>
                      </li>
                    ))}
                  </ol>
                </div>
              ))
            : NOTES_LIVE && notes.length
              ? [...new Set(notes.map((x) => x.subject))].map((subject) => (
                  <div key={subject}>
                    <h2 className="ab-title border-b border-ab-ink pb-3 text-2xl">{subjectName(subject, locale)}</h2>
                    <ul className="mt-2">
                      {notes
                        .filter((x) => x.subject === subject)
                        .map((note) => (
                          <li key={note.id} className="border-b border-ab-rule py-1">
                            <Link href={`/notes/${note.id}`} className={row}>
                              <PdfBadge size={30} />
                              <span className="flex-1 font-medium">{note.title}</span>
                              <Arrow className="text-ab-ink-3" />
                            </Link>
                          </li>
                        ))}
                    </ul>
                  </div>
                ))
              : SUBJECTS.map((subject) => (
                  <div key={subject}>
                    <div className="flex items-center justify-between gap-4 border-b border-ab-ink pb-3">
                      <h2 className="ab-title text-2xl">{t.common.subjects[subject]}</h2>
                      <Pill>{t.common.comingSoon}</Pill>
                    </div>
                    <ol className="mt-1">
                      {syllabus[subject].map((chapter, i) => (
                        <li key={chapter} className="flex gap-3 border-b border-ab-rule px-1 py-3 text-[15px] text-ab-ink-2">
                          <span className="ab-num w-6 shrink-0 text-[13px] text-ab-ink-3">{String(i + 1).padStart(2, "0")}</span>
                          {chapter}
                        </li>
                      ))}
                    </ol>
                  </div>
                ))}
        </div>
      </section>
    </>
  );
}
