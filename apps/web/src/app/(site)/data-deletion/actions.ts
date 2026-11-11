"use server";

import { revalidatePath } from "next/cache";
import { getLocale } from "@/lib/i18n/server";
import { createServerClient } from "@/lib/supabase/server";

export type DeletionResult = { error?: string; ok?: boolean };

/** File a data or account deletion request as the signed-in student. */
export async function requestDeletion(_: DeletionResult, formData: FormData): Promise<DeletionResult> {
  const hi = (await getLocale()) === "hi";
  const kind = String(formData.get("kind") ?? "");
  const reason = String(formData.get("reason") ?? "").slice(0, 1000);
  if (kind !== "data" && kind !== "account") return { error: hi ? "चुनें कि क्या हटाना है।" : "Choose what you want deleted." };
  if (formData.get("confirm") !== "on") return { error: hi ? "पुष्टि के लिए बॉक्स पर टिक करें।" : "Tick the box to confirm you understand." };

  const supabase = await createServerClient();
  if (!supabase) return { error: hi ? "अभी अनुरोध नहीं भेजे जा सकते। कृपया हमें ईमेल करें।" : "Requests are not available right now. Email us instead." };
  const { error } = await supabase.rpc("request_deletion", { p_kind: kind, p_reason: reason });
  if (error) return { error: hi ? "आपका अनुरोध नहीं भेजा जा सका। फिर कोशिश करें या हमें ईमेल करें।" : "Your request could not be sent. Try again, or email us." };

  revalidatePath("/data-deletion");
  return { ok: true };
}

/** Withdraw a request that is still pending. */
export async function cancelDeletion(formData: FormData) {
  const id = String(formData.get("id") ?? "");
  const supabase = await createServerClient();
  if (!supabase || !id) return;
  await supabase.rpc("cancel_deletion_request", { p_id: id });
  revalidatePath("/data-deletion");
}
