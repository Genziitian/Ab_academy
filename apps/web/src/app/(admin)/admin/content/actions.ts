"use server";

import { revalidatePath } from "next/cache";
import { requireAdmin } from "@/lib/admin/auth";
import {
  addResource,
  deleteLesson,
  deleteResource,
  saveLesson,
  uploadToBucket,
} from "@/lib/admin/data";
import type { AdminLesson } from "@/lib/admin/types";

/**
 * Creates or updates a lesson, and uploads a video file if one was attached.
 *
 * Two ways to attach a recording: a YouTube id (the cheap path, which is what
 * live classes already use) or an mp4 uploaded to the private lesson-videos
 * bucket and played back through a signed URL.
 */
export async function saveLessonAction(formData: FormData) {
  await requireAdmin();

  const id = String(formData.get("id") ?? "").trim() || undefined;
  const videoFile = formData.get("videoFile");
  const youtubeId = String(formData.get("videoRef") ?? "").trim();

  let videoProvider: string | null = null;
  let videoRef: string | null = null;

  if (videoFile instanceof File && videoFile.size > 0) {
    await uploadToBucket("lesson-videos", videoFile, "lessons");
    videoProvider = "storage";
  } else if (youtubeId) {
    videoProvider = "youtube";
    videoRef = youtubeId;
  }

  const minutes = Number(formData.get("durationMinutes") ?? 0);

  await saveLesson({
    id,
    title: String(formData.get("title") ?? "").trim(),
    lessonType: String(
      formData.get("lessonType") ?? "VIDEO",
    ) as AdminLesson["lessonType"],
    courseId: String(formData.get("courseId") ?? ""),
    subjectName: String(formData.get("subjectName") ?? "").trim() || "General",
    chapterTitle: String(formData.get("chapterTitle") ?? "").trim() || "Chapter 01",
    durationSeconds: minutes > 0 ? minutes * 60 : null,
    videoProvider,
    videoRef,
    isPublished: formData.get("isPublished") !== null,
    isDemo: formData.get("isDemo") !== null,
    isDownloadable: formData.get("isDownloadable") !== null,
  });

  revalidatePath("/admin/content");
  revalidatePath("/admin");
}

export async function deleteLessonAction(formData: FormData) {
  await requireAdmin();
  await deleteLesson(String(formData.get("id") ?? ""));
  revalidatePath("/admin/content");
  revalidatePath("/admin");
}

/** Uploads a notes PDF to the private bucket and links it to the lesson. */
export async function addResourceAction(formData: FormData) {
  await requireAdmin();

  const lessonId = String(formData.get("lessonId") ?? "");
  const file = formData.get("file");
  if (!(file instanceof File) || file.size === 0) return;

  const storagePath = await uploadToBucket("lesson-notes", file, lessonId);

  await addResource({
    lessonId,
    title: String(formData.get("title") ?? "").trim() || file.name,
    storagePath,
    sizeBytes: file.size,
  });

  revalidatePath("/admin/content");
}

export async function deleteResourceAction(formData: FormData) {
  await requireAdmin();
  await deleteResource(
    String(formData.get("lessonId") ?? ""),
    String(formData.get("resourceId") ?? ""),
  );
  revalidatePath("/admin/content");
}
