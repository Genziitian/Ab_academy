import { redirect } from "next/navigation";
import { createServerClient, hasSupabaseEnv } from "@/lib/supabase/server";

export type AdminRole = "admin" | "super_admin" | "teacher";

export type AdminUser = {
  id: string;
  name: string;
  email: string;
  role: AdminRole;
};

const STAFF_ROLES: AdminRole[] = ["admin", "super_admin", "teacher"];

/**
 * True when the console is running without a Supabase project. The admin UI
 * then reads the mock store and every page shows a "demo data" banner.
 * With env vars present this is false and real access control applies.
 */
export function isDemoMode() {
  return !hasSupabaseEnv();
}

/**
 * The signed-in staff member, or a redirect to /login.
 *
 * Authorisation is enforced twice on purpose: here, so an unauthorised visitor
 * never sees the console, and in Postgres via `is_staff()` / `is_admin()` RLS
 * policies, so a bug here cannot turn into a data leak.
 */
export async function requireAdmin(): Promise<AdminUser> {
  if (isDemoMode()) {
    return {
      id: "demo",
      name: "Demo Admin",
      email: "admin@akhandbharatacademy.in",
      role: "super_admin",
    };
  }

  const supabase = await createServerClient();
  if (!supabase) redirect("/login?next=/admin");

  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login?next=/admin");

  const { data: profile } = await supabase
    .from("profiles")
    .select("id, full_name, email, role")
    .eq("id", user.id)
    .maybeSingle();

  const role = profile?.role as AdminRole | undefined;
  if (!role || !STAFF_ROLES.includes(role)) {
    // A signed-in student who guessed the URL. Send them to the site rather
    // than /login, which would bounce them straight back here.
    redirect("/?error=not-staff");
  }

  return {
    id: user.id,
    name: profile?.full_name || user.email || "Staff",
    email: profile?.email || user.email || "",
    role,
  };
}

/** Course/pricing/enrolment changes are admin-only; teachers are read-mostly. */
export async function requireFullAdmin(): Promise<AdminUser> {
  const admin = await requireAdmin();
  if (admin.role === "teacher") redirect("/admin?error=admin-only");
  return admin;
}
