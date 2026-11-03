"use server";

import { revalidatePath } from "next/cache";
import { requireAdmin } from "@/lib/admin/auth";
import {
  addChapter,
  addResource,
  deleteChapter,
  deleteLesson,
  deleteResource,
  moveChapter,
  renameChapter,
  saveLesson,
  uploadToBucket,
} from "@/lib/admin/data";
import { driveFileId } from "@/lib/admin/drive";
import { youtubeId } from "@/lib/admin/youtube";
import type { AdminLesson } from "@/lib/admin/types";

const text = (fd: FormData, key: string) => String(fd.get(key) ?? "").trim();

function refresh(courseId: string) {
  revalidatePath(`/admin/courses/${courseId}`);
  revalidatePath("/admin/courses");
  revalidatePath("/admin");
}

/** Add or edit a lecture inside a chapter, with an optional notes PDF. */
export async function saveLectureAction(fd: FormData) {
  await requireAdmin();
  const courseId = text(fd, "courseId");
  const title = text(fd, "title");
  if (!title) throw new Error("Give the lecture a title.");

  const youtube = text(fd, "youtube");
  const file = fd.get("videoFile");
  let videoProvider: string | null = null;
  let videoRef: string | null = null;
  let storagePath: string | null = null;
  if (file instanceof File && file.size > 0) {
    storagePath = await uploadToBucket("lesson-videos", file, "lessons");
    videoProvider = "storage";
  } else if (youtube) {
    videoRef = youtubeId(youtube);
    if (!videoRef) throw new Error("That YouTube link was not recognised. Paste the full video link.");
    videoProvider = "youtube";
  }

  const minutes = Number(fd.get("minutes") ?? 0);
  const id = await saveLesson({
    id: text(fd, "id") || undefined,
    title,
    lessonType: (text(fd, "lessonType") || "VIDEO") as AdminLesson["lessonType"],
    courseId,
    chapterId: text(fd, "chapterId"),
    subjectName: "",
    chapterTitle: "",
    durationSeconds: minutes > 0 ? minutes * 60 : null,
    videoProvider,
    videoRef,
    storagePath,
    isPublished: fd.get("isPublished") === "on",
    isDemo: fd.get("isDemo") === "on",
    isDownloadable: false,
  });

  const notes = text(fd, "notesLink");
  if (notes) {
    const fileId = driveFileId(notes);
    if (!fileId) throw new Error("The notes link must be a Google Drive file link.");
    await addResource({ lessonId: id, title: text(fd, "notesTitle") || `${title} — notes`, driveFileId: fileId, sizeBytes: null });
  }
  refresh(courseId);
}

export async function deleteLectureAction(fd: FormData) {
  await requireAdmin();
  await deleteLesson(text(fd, "id"));
  refresh(text(fd, "courseId"));
}

export async function deleteNotesAction(fd: FormData) {
  await requireAdmin();
  await deleteResource(text(fd, "lessonId"), text(fd, "resourceId"));
  refresh(text(fd, "courseId"));
}

export async function addChapterAction(fd: FormData) {
  await requireAdmin();
  const title = text(fd, "title");
  if (!title) throw new Error("Give the chapter a name.");
  await addChapter(text(fd, "courseId"), text(fd, "subject") || "General", title);
  refresh(text(fd, "courseId"));
}

export async function renameChapterAction(fd: FormData) {
  await requireAdmin();
  const title = text(fd, "title");
  if (!title) throw new Error("The chapter name cannot be empty.");
  await renameChapter(text(fd, "id"), title);
  refresh(text(fd, "courseId"));
}

export async function deleteChapterAction(fd: FormData) {
  await requireAdmin();
  await deleteChapter(text(fd, "id"));
  refresh(text(fd, "courseId"));
}

export async function moveChapterAction(fd: FormData) {
  await requireAdmin();
  await moveChapter(text(fd, "id"), text(fd, "direction") === "up" ? "up" : "down");
  refresh(text(fd, "courseId"));
}
