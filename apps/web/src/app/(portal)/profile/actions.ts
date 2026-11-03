"use server";

import { revalidatePath } from "next/cache";
import { createServerClient } from "@/lib/supabase/server";

/** Saves the student's name, class and study language. */
export async function saveProfileAction(fd: FormData) {
  const supabase = await createServerClient();
  const { data } = (await supabase?.auth.getUser()) ?? { data: { user: null } };
  if (!supabase || !data.user) throw new Error("Sign in again.");
  const name = String(fd.get("name") ?? "").trim().slice(0, 80);
  const classLevel = Number(fd.get("classLevel"));
  const medium = String(fd.get("medium") ?? "");
  if (name) await supabase.from("profiles").update({ full_name: name }).eq("id", data.user.id);
  await supabase.from("student_profiles").upsert(
    {
      user_id: data.user.id,
      class_level: classLevel >= 9 && classLevel <= 12 ? classLevel : null,
      medium: ["Hindi", "Hinglish", "English"].includes(medium) ? medium : null,
    },
    { onConflict: "user_id" },
  );
  revalidatePath("/", "layout");
}
