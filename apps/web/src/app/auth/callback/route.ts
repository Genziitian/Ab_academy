import { NextResponse, type NextRequest } from "next/server";
import { safeNext } from "@/lib/safe-next";
import { createServerClient } from "@/lib/supabase/server";

/**
 * Exchanges the OAuth / magic-link code for a session cookie, then forwards to
 * `next`. Supabase redirects here after Google sign-in or an email link.
 */
export async function GET(request: NextRequest) {
  const { searchParams, origin } = request.nextUrl;
  const code = searchParams.get("code");
  const next = safeNext(searchParams.get("next"), "/dashboard");

  if (!code) {
    return NextResponse.redirect(`${origin}/login?error=missing-code`);
  }

  const supabase = await createServerClient();
  if (!supabase) {
    return NextResponse.redirect(`${origin}/login?error=not-configured`);
  }

  const { error } = await supabase.auth.exchangeCodeForSession(code);
  if (error) {
    console.error("auth callback failed:", error.message);
    return NextResponse.redirect(`${origin}/login?error=sign-in-failed`);
  }

  return NextResponse.redirect(`${origin}${next}`);
}
