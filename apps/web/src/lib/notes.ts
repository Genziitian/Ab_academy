// Free notes library: subject → chapter → notes (Google Drive PDFs).
// Read by the public /notes page and edited in Admin → Free notes.

import { createServerClient } from "@/lib/supabase/server";

export type FreeNote = { id: string; title: string; driveFileId: string; isPublished: boolean };
export type FreeChapter = { id: string; title: string; notes: FreeNote[] };
export type FreeSubject = { id: string; name: string; chapters: FreeChapter[] };

type Row = {
  id: string;
  name: string;
  sort_order: number;
  free_note_chapters: {
    id: string;
    title: string;
    sort_order: number;
    free_notes: { id: string; title: string; drive_file_id: string; is_published: boolean; sort_order: number }[];
  }[];
};

const bySort = <T extends { sort_order: number }>(a: T, b: T) => a.sort_order - b.sort_order;

/** The whole library. Visitors get published notes only (RLS). */
export async function getFreeNotes(): Promise<FreeSubject[]> {
  const supabase = await createServerClient();
  if (!supabase) return [];
  const { data, error } = await supabase
    .from("free_note_subjects")
    .select(
      "id, name, sort_order, free_note_chapters ( id, title, sort_order, free_notes ( id, title, drive_file_id, is_published, sort_order ) )",
    )
    .order("sort_order");
  // Before the migration runs the table is missing; show "coming soon".
  if (error || !data) return [];
  return (data as unknown as Row[]).sort(bySort).map((s) => ({
    id: s.id,
    name: s.name,
    chapters: [...s.free_note_chapters].sort(bySort).map((c) => ({
      id: c.id,
      title: c.title,
      notes: [...c.free_notes].sort(bySort).map((n) => ({
        id: n.id,
        title: n.title,
        driveFileId: n.drive_file_id,
        isPublished: n.is_published,
      })),
    })),
  }));
}

export async function getFreeNote(id: string) {
  const supabase = await createServerClient();
  if (!supabase) return null;
  const { data } = await supabase
    .from("free_notes")
    .select("id, title, drive_file_id, free_note_chapters ( title, free_note_subjects ( name ) )")
    .eq("id", id)
    .maybeSingle();
  if (!data) return null;
  const chapter = data.free_note_chapters as unknown as { title: string; free_note_subjects: { name: string } | null } | null;
  return {
    id: data.id as string,
    title: data.title as string,
    driveFileId: data.drive_file_id as string,
    chapter: chapter?.title ?? "",
    subject: chapter?.free_note_subjects?.name ?? "",
  };
}

/** Next sort position at the end of a list. */
export async function nextSort(table: string, column?: string, value?: string) {
  const supabase = await createServerClient();
  if (!supabase) return 1;
  let q = supabase.from(table).select("sort_order").order("sort_order", { ascending: false }).limit(1);
  if (column && value) q = q.eq(column, value);
  const { data } = await q.maybeSingle();
  return ((data as { sort_order?: number } | null)?.sort_order ?? 0) + 1;
}
