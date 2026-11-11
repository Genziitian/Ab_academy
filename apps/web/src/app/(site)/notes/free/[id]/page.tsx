import Link from "next/link";
import { notFound } from "next/navigation";
import { subjectName } from "@/lib/i18n/content";
import { getT } from "@/lib/i18n/server";
import { getFreeNote } from "@/lib/notes";

export async function generateMetadata({ params }: { params: Promise<{ id: string }> }) {
  const note = await getFreeNote((await params).id);
  return { title: note ? `${note.title} · ${note.subject}` : "Notes" };
}

/** A free notes PDF in Google Drive's viewer. */
export default async function FreeNotePage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const [note, { t, locale }] = await Promise.all([getFreeNote(id), getT()]);
  if (!note) notFound();

  return (
    <section className="mx-auto max-w-[1080px] px-4 pb-16 pt-8 sm:px-6">
      <Link href="/notes" className="text-sm text-ab-ink-2 hover:text-ab-ink">
        ← {t.notes.all}
      </Link>
      <p className="ab-eyebrow mt-6">
        {subjectName(note.subject, locale)} · {note.chapter}
      </p>
      <h1 className="ab-display mt-2 text-[34px] sm:text-[44px]">{note.title}</h1>
      <div className="mt-6 overflow-hidden rounded-2xl border border-ab-rule bg-ab-panel">
        <iframe
          src={`https://drive.google.com/file/d/${encodeURIComponent(note.driveFileId)}/preview`}
          title={note.title}
          className="h-[78vh] w-full"
          allow="autoplay"
        />
      </div>
      <p className="mt-4 text-sm text-ab-ink-2">
        {t.notes.wantMore}{" "}
        <Link href="/#courses" className="font-medium text-ab-ink underline decoration-ab-rule-strong underline-offset-4 hover:decoration-ab-ink">
          {t.notes.seeCourses}
        </Link>
      </p>
    </section>
  );
}
