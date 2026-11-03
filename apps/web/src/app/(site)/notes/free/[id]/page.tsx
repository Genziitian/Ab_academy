import Link from "next/link";
import { notFound } from "next/navigation";
import { getFreeNote } from "@/lib/notes";

export async function generateMetadata({ params }: { params: Promise<{ id: string }> }) {
  const note = await getFreeNote((await params).id);
  return { title: note ? `${note.title} · ${note.subject}` : "Notes" };
}

/** A free notes PDF in Google Drive's viewer. */
export default async function FreeNotePage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const note = await getFreeNote(id);
  if (!note) notFound();

  return (
    <section className="mx-auto max-w-[1080px] px-4 pb-16 pt-8 sm:px-6">
      <Link href="/notes" className="text-sm font-semibold text-clay hover:underline">
        ← All notes
      </Link>
      <p className="mt-6 text-xs font-bold uppercase tracking-[0.14em] text-clay">
        {note.subject} · {note.chapter}
      </p>
      <h1 className="mt-2 font-serif text-[40px] leading-none tracking-[-0.02em] sm:text-[52px]">{note.title}</h1>
      <div className="mt-6 overflow-hidden rounded-[22px] border border-sand bg-white">
        <iframe
          src={`https://drive.google.com/file/d/${encodeURIComponent(note.driveFileId)}/preview`}
          title={note.title}
          className="h-[78vh] w-full"
          allow="autoplay"
        />
      </div>
      <p className="mt-4 text-sm text-taupe">
        Want every chapter taught step by step?{" "}
        <Link href="/#courses" className="font-semibold text-clay hover:underline">
          See the Class 12 crash courses →
        </Link>
      </p>
    </section>
  );
}
