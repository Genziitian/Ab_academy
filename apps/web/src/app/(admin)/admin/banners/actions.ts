"use server";

import { revalidatePath } from "next/cache";
import { requireAdmin } from "@/lib/admin/auth";
import { deleteBanner, saveBanner, uploadToBucket } from "@/lib/admin/data";

export async function saveBannerAction(formData: FormData) {
  await requireAdmin();

  const image = formData.get("image");
  // `undefined` leaves the existing artwork alone; a File replaces it, and
  // ticking "remove" clears it back to the gradient.
  let imagePath: string | null | undefined = undefined;
  if (image instanceof File && image.size > 0) {
    imagePath = await uploadToBucket("banner-images", image, "banners");
  } else if (formData.get("removeImage") !== null) {
    imagePath = null;
  }

  const hue = Number(formData.get("hue") ?? 214);

  await saveBanner({
    id: String(formData.get("id") ?? "").trim() || undefined,
    title: String(formData.get("title") ?? "").trim(),
    subtitle: String(formData.get("subtitle") ?? "").trim() || null,
    imagePath,
    courseId: String(formData.get("courseId") ?? "").trim() || null,
    ctaLabel: String(formData.get("ctaLabel") ?? "").trim() || "View course",
    hue: Number.isFinite(hue) ? Math.min(360, Math.max(0, hue)) : 214,
    sortOrder: Number(formData.get("sortOrder") ?? 0),
    isActive: formData.get("isActive") !== null,
    startsAt: String(formData.get("startsAt") ?? "") || new Date().toISOString(),
    endsAt: String(formData.get("endsAt") ?? "").trim() || null,
  });

  revalidatePath("/admin/banners");
}

export async function deleteBannerAction(formData: FormData) {
  await requireAdmin();
  await deleteBanner(String(formData.get("id") ?? ""));
  revalidatePath("/admin/banners");
}
