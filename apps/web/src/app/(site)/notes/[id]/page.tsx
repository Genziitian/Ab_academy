import Link from "next/link";
import { notFound, redirect } from "next/navigation";
import { SecurePdfViewer } from "@/components/notes/SecurePdfViewer";
import { NOTES_LIVE } from "@/lib/landing";
import { createServerClient } from "@/lib/supabase/server";

export const metadata = { title: "Notes", robots: { index: false } };

/** One note in the secure viewer. Signed-in students only. */
export default async function NoteViewerPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  if (!NOTES_LIVE || !/^[0-9a-f-]{36}$/i.test(id)) notFound();

  const supabase = await createServerClient();
  if (!supabase) notFound();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect(`/login?next=/notes/${id}`);

  // RLS returns the row only if this student may read the note.
  const [{ data: note }, { data: profile }] = await Promise.all([
    supabase.from("lesson_resources").select("id, title").eq("id", id).maybeSingle(),
    supabase.from("profiles").select("phone, email, student_code").eq("id", user.id).maybeSingle(),
  ]);
  if (!note) notFound();

  const watermark = [profile?.phone ?? profile?.email ?? user.email, profile?.student_code]
    .filter(Boolean)
    .join(" · ");

  return (
    <section className="mx-auto max-w-[960px] px-4 py-10 sm:px-6 lg:py-14">
      <Link href="/notes" className="text-sm font-semibold text-clay hover:underline">
        ← All notes
      </Link>
      <h1 className="mt-3 font-serif text-[40px] leading-none sm:text-[56px]">{note.title}</h1>
      <p className="mt-2 text-sm text-taupe">Read here only — notes can’t be downloaded or shared.</p>
      <div className="mt-8">
        <SecurePdfViewer resourceId={note.id} watermark={watermark} />
      </div>
    </section>
  );
}
