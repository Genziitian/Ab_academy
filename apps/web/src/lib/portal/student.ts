import { cache } from "react";
import { redirect } from "next/navigation";
import { initials } from "@/lib/courses";
import { createServerClient, hasSupabaseEnv } from "@/lib/supabase/server";

export type Student = {
  id: string;
  name: string;
  firstName: string;
  initials: string;
  phone: string | null;
  email: string | null;
  classLevel: number | null;
  board: string;
  medium: string | null;
  stream: string | null;
  /** "Class 12 · Bihar Board", used under the name in the top bar. */
  summary: string;
};

const DEMO: Omit<Student, "summary" | "initials" | "firstName"> = {
  id: "demo",
  name: "Rahul Kumar",
  phone: "+91 98765 43210",
  email: null,
  classLevel: 12,
  board: "Bihar Board",
  medium: "Hindi",
  stream: "Science",
};

function finish(s: Omit<Student, "summary" | "initials" | "firstName">): Student {
  const parts = [s.classLevel ? `Class ${s.classLevel}` : null, s.board].filter(Boolean);
  return {
    ...s,
    firstName: s.name.split(" ")[0] ?? s.name,
    initials: initials(s.name) || "ST",
    summary: parts.join(" · "),
  };
}

/**
 * The signed-in student, or a redirect to /login. Without Supabase the portal
 * runs as a demo student so every page can be previewed.
 *
 * Wrapped in `cache` so the layout and the page share one lookup per request.
 */
export const getStudent = cache(async (): Promise<Student> => {
  if (!hasSupabaseEnv()) return finish(DEMO);

  const supabase = await createServerClient();
  if (!supabase) return finish(DEMO);

  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login?next=/dashboard");

  const [{ data: profile }, { data: details }] = await Promise.all([
    supabase.from("profiles").select("full_name, phone").eq("id", user.id).maybeSingle(),
    supabase
      .from("student_profiles")
      .select("class_level, board, medium, stream")
      .eq("user_id", user.id)
      .maybeSingle(),
  ]);

  return finish({
    id: user.id,
    name: profile?.full_name || user.user_metadata?.full_name || user.email || "Student",
    phone: profile?.phone ?? user.phone ?? null,
    email: user.email ?? null,
    classLevel: details?.class_level ?? null,
    board: details?.board ?? "Bihar Board",
    medium: details?.medium ?? null,
    stream: details?.stream ?? null,
  });
});

export function isPortalDemo() {
  return !hasSupabaseEnv();
}
