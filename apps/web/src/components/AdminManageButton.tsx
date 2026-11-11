"use client";

import { createBrowserClient } from "@supabase/ssr";
import Link from "next/link";
import { useEffect, useState } from "react";

/**
 * Floating "Manage course" link on the public course page, shown only to
 * admins. Checked in the browser so the page itself stays static and fast;
 * the admin console enforces access on its own.
 */
export function AdminManageButton({ courseId, label = "Manage course" }: { courseId: string; label?: string }) {
  const [isAdmin, setIsAdmin] = useState(false);

  useEffect(() => {
    const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
    const key = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;
    if (!url || !key) return;
    const supabase = createBrowserClient(url, key);
    let alive = true;
    (async () => {
      const { data } = await supabase.auth.getSession();
      const uid = data.session?.user.id;
      if (!uid) return;
      const { data: profile } = await supabase.from("profiles").select("role").eq("id", uid).maybeSingle();
      if (alive && (profile?.role === "admin" || profile?.role === "super_admin")) setIsAdmin(true);
    })();
    return () => {
      alive = false;
    };
  }, []);

  if (!isAdmin) return null;
  return (
    <Link
      href={`/admin/courses/${courseId}`}
      className="fixed bottom-24 left-1/2 z-50 flex h-11 -translate-x-1/2 items-center gap-2 rounded-full bg-ab-ink px-5 text-sm font-medium text-white shadow-[0_14px_40px_-12px_rgba(23,21,17,0.45)] hover:bg-black lg:bottom-6"
    >
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" aria-hidden>
        <path d="M17 3a2.8 2.8 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5z" />
      </svg>
      {label}
    </Link>
  );
}
