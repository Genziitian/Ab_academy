"use server";

import { revalidatePath } from "next/cache";
import { requireAdmin } from "@/lib/admin/auth";
import { driveFileId } from "@/lib/admin/drive";
import { nextSort } from "@/lib/notes";
import { createServerClient } from "@/lib/supabase/server";

const text = (fd: FormData, key: string) => String(fd.get(key) ?? "").trim();

async function client() {
  await requireAdmin();
  const supabase = await createServerClient();
  if (!supabase) throw new Error("Free notes need a connected Supabase project.");
  return supabase;
}

function done() {
  revalidatePath("/admin/notes");
  revalidatePath("/notes", "layout");
}

function check(error: { message: string } | null) {
  if (!error) return;
  if (/free_note/.test(error.message) && /does not exist|schema cache/.test(error.message)) {
    throw new Error("Run the free notes migration (20261103000400_free_notes.sql) in Supabase first.");
  }
  throw new Error(error.message);
}

export async function addSubjectAction(fd: FormData) {
  const supabase = await client();
  const name = text(fd, "name");
  if (!name) throw new Error("Give the subject a name.");
  const { error } = await supabase
    .from("free_note_subjects")
    .insert({ name, sort_order: await nextSort("free_note_subjects") });
  check(error);
  done();
}

export async function renameSubjectAction(fd: FormData) {
  const supabase = await client();
  const name = text(fd, "name");
  if (!name) throw new Error("The subject name cannot be empty.");
  check((await supabase.from("free_note_subjects").update({ name }).eq("id", text(fd, "id"))).error);
  done();
}

export async function deleteSubjectAction(fd: FormData) {
  const supabase = await client();
  check((await supabase.from("free_note_subjects").delete().eq("id", text(fd, "id"))).error);
  done();
}

export async function addChapterAction(fd: FormData) {
  const supabase = await client();
  const title = text(fd, "title");
  const subjectId = text(fd, "subjectId");
  if (!title) throw new Error("Give the chapter a name.");
  const { error } = await supabase.from("free_note_chapters").insert({
    subject_id: subjectId,
    title,
    sort_order: await nextSort("free_note_chapters", "subject_id", subjectId),
  });
  check(error);
  done();
}

export async function renameChapterAction(fd: FormData) {
  const supabase = await client();
  const title = text(fd, "title");
  if (!title) throw new Error("The chapter name cannot be empty.");
  check((await supabase.from("free_note_chapters").update({ title }).eq("id", text(fd, "id"))).error);
  done();
}

export async function deleteChapterAction(fd: FormData) {
  const supabase = await client();
  check((await supabase.from("free_note_chapters").delete().eq("id", text(fd, "id"))).error);
  done();
}

export async function saveNoteAction(fd: FormData) {
  const supabase = await client();
  const title = text(fd, "title");
  if (!title) throw new Error("Give the notes a title.");
  const id = text(fd, "id");
  const link = text(fd, "link");
  const fileId = link ? driveFileId(link) : null;
  if (link && !fileId) throw new Error("That is not a Google Drive file link.");
  const isPublished = fd.get("isPublished") === "on";

  if (id) {
    check(
      (
        await supabase
          .from("free_notes")
          .update({ title, is_published: isPublished, ...(fileId ? { drive_file_id: fileId } : {}) })
          .eq("id", id)
      ).error,
    );
  } else {
    if (!fileId) throw new Error("Paste the Google Drive link of the PDF.");
    const chapterId = text(fd, "chapterId");
    check(
      (
        await supabase.from("free_notes").insert({
          chapter_id: chapterId,
          title,
          drive_file_id: fileId,
          is_published: isPublished,
          sort_order: await nextSort("free_notes", "chapter_id", chapterId),
        })
      ).error,
    );
  }
  done();
}

export async function deleteNoteAction(fd: FormData) {
  const supabase = await client();
  check((await supabase.from("free_notes").delete().eq("id", text(fd, "id"))).error);
  done();
}
