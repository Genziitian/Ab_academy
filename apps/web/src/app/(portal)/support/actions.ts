"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { createServerClient } from "@/lib/supabase/server";

const CATEGORIES = ["payment", "content", "technical", "account", "other"] as const;

async function me() {
  const supabase = await createServerClient();
  const { data } = (await supabase?.auth.getUser()) ?? { data: { user: null } };
  if (!supabase || !data.user) throw new Error("Sign in again to contact support.");
  return { supabase, id: data.user.id };
}

export async function createTicketAction(fd: FormData) {
  const { supabase, id } = await me();
  const subject = String(fd.get("subject") ?? "").trim();
  const body = String(fd.get("body") ?? "").trim();
  const category = String(fd.get("category") ?? "other");
  if (!subject || !body) throw new Error("Add a subject and describe the problem.");
  const reference = `ABA-T-${Date.now().toString(36).toUpperCase().slice(-6)}`;
  const { data, error } = await supabase
    .from("tickets")
    .insert({
      student_id: id,
      reference,
      subject: subject.slice(0, 140),
      category: (CATEGORIES as readonly string[]).includes(category) ? category : "other",
    })
    .select("id")
    .single();
  if (error || !data) throw new Error("Could not create the ticket. Please try again.");
  await supabase.from("ticket_messages").insert({ ticket_id: data.id, author_id: id, body: body.slice(0, 4000) });
  revalidatePath("/support");
  redirect(`/support/${data.id}`);
}

export async function replyTicketAction(fd: FormData) {
  const { supabase, id } = await me();
  const ticketId = String(fd.get("ticketId") ?? "");
  const body = String(fd.get("body") ?? "").trim();
  if (!body) return;
  await supabase.from("ticket_messages").insert({ ticket_id: ticketId, author_id: id, body: body.slice(0, 4000) });
  revalidatePath(`/support/${ticketId}`);
}
