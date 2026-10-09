"use server";

import { revalidatePath } from "next/cache";
import { requireAdmin } from "@/lib/admin/auth";
import { deletePopup, savePopup, uploadToBucket } from "@/lib/admin/data";
import type { AudienceKind, PopupPlacement } from "@/lib/admin/types";

export async function savePopupAction(formData: FormData) {
  await requireAdmin();

  const audienceKind = String(formData.get("audienceKind") ?? "all") as AudienceKind;
  const rawAudience = String(formData.get("audienceValue") ?? "").trim();

  const image = formData.get("image");
  // `undefined` leaves the existing image alone; a File replaces it.
  let imagePath: string | null | undefined = undefined;
  if (image instanceof File && image.size > 0) {
    imagePath = await uploadToBucket("popup-images", image, "popups");
  }

  const ctaLabel = String(formData.get("ctaLabel") ?? "").trim() || null;
  const ctaUrl = String(formData.get("ctaUrl") ?? "").trim() || null;

  await savePopup({
    id: String(formData.get("id") ?? "").trim() || undefined,
    title: String(formData.get("title") ?? "").trim(),
    body: String(formData.get("body") ?? "").trim(),
    imagePath,
    // The DB constrains the CTA to both halves or neither.
    ctaLabel: ctaLabel && ctaUrl ? ctaLabel : null,
    ctaUrl: ctaLabel && ctaUrl ? ctaUrl : null,
    placement: String(formData.get("placement") ?? "app_launch") as PopupPlacement,
    audienceKind,
    audienceValue: audienceKind === "all" ? null : rawAudience || null,
    isActive: formData.get("isActive") !== null,
    startsAt: String(formData.get("startsAt") ?? "") || new Date().toISOString(),
    endsAt: String(formData.get("endsAt") ?? "").trim() || null,
    maxViewsPerStudent: Number(formData.get("maxViewsPerStudent") ?? 1),
    priority: Number(formData.get("priority") ?? 0),
  });

  revalidatePath("/admin/popups");
  revalidatePath("/admin");
}

export async function deletePopupAction(formData: FormData) {
  await requireAdmin();
  await deletePopup(String(formData.get("id") ?? ""));
  revalidatePath("/admin/popups");
  revalidatePath("/admin");
}
