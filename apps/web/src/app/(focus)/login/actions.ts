"use server";

import { headers } from "next/headers";
import { redirect } from "next/navigation";
import { createServerClient } from "@/lib/supabase/server";

export type LoginState = { error?: string; sent?: boolean; phone?: string };

const NOT_CONFIGURED = "Supabase is not configured. Set the env vars first.";

/** Only same-site paths, so `next` cannot turn sign-in into an open redirect. */
function safeNext(value: FormDataEntryValue | null, fallback: string) {
  const next = String(value ?? "");
  return next.startsWith("/") && !next.startsWith("//") ? next : fallback;
}

/** Staff sign-in. Email + password is the only flow the console needs. */
export async function signInWithPassword(
  _prev: LoginState,
  formData: FormData,
): Promise<LoginState> {
  const email = String(formData.get("email") ?? "").trim();
  const password = String(formData.get("password") ?? "");
  const next = safeNext(formData.get("next"), "/admin");

  if (!email || !password) return { error: "Email and password are required." };

  const supabase = await createServerClient();
  if (!supabase) return { error: NOT_CONFIGURED };

  const { error } = await supabase.auth.signInWithPassword({ email, password });
  if (error) return { error: error.message };

  redirect(next);
}

/** Student sign-in: phone OTP. Step 1 — send the code. */
export async function sendPhoneOtp(
  _prev: LoginState,
  formData: FormData,
): Promise<LoginState> {
  const raw = String(formData.get("phone") ?? "").replace(/\D/g, "");
  if (raw.length < 10) return { error: "Enter a valid 10-digit mobile number." };
  const phone = `+91${raw.slice(-10)}`;

  const supabase = await createServerClient();
  if (!supabase) return { error: NOT_CONFIGURED };

  const { error } = await supabase.auth.signInWithOtp({ phone });
  if (error) return { error: error.message };

  return { sent: true, phone };
}

/** Student sign-in: phone OTP. Step 2 — check the code and start a session. */
export async function verifyPhoneOtp(
  _prev: LoginState,
  formData: FormData,
): Promise<LoginState> {
  const phone = String(formData.get("phone") ?? "");
  const token = String(formData.get("token") ?? "").replace(/\D/g, "");
  const next = safeNext(formData.get("next"), "/dashboard");

  if (token.length !== 6) return { sent: true, phone, error: "Enter the 6-digit code." };

  const supabase = await createServerClient();
  if (!supabase) return { error: NOT_CONFIGURED };

  const { error } = await supabase.auth.verifyOtp({ phone, token, type: "sms" });
  if (error) return { sent: true, phone, error: error.message };

  redirect(next);
}

/**
 * Google sign-in. Returns a consent URL that we redirect to; Google then sends
 * the user back to /auth/callback, which swaps the code for a session cookie.
 *
 * The PKCE verifier is written to a cookie here — that only works because this
 * is a Server Action. Calling it from a Server Component would silently drop
 * the cookie and the callback would fail to exchange the code.
 */
export async function signInWithGoogle(
  _prev: LoginState,
  formData: FormData,
): Promise<LoginState> {
  const next = safeNext(formData.get("next"), "/dashboard");

  const supabase = await createServerClient();
  if (!supabase) return { error: NOT_CONFIGURED };

  const { data, error } = await supabase.auth.signInWithOAuth({
    provider: "google",
    options: {
      redirectTo: `${await siteOrigin()}/auth/callback?next=${encodeURIComponent(next)}`,
    },
  });

  if (error) return { error: error.message };
  if (!data.url) return { error: "Google sign-in is not enabled yet." };

  redirect(data.url);
}

/**
 * Origin to send Google back to. NEXT_PUBLIC_SITE_URL wins so that a spoofed
 * Host header cannot steer the callback; the request host is the fallback that
 * keeps localhost and preview deploys working.
 */
async function siteOrigin() {
  if (process.env.NEXT_PUBLIC_SITE_URL) {
    return process.env.NEXT_PUBLIC_SITE_URL.replace(/\/$/, "");
  }

  const headerList = await headers();
  const host = headerList.get("x-forwarded-host") ?? headerList.get("host");
  const proto =
    headerList.get("x-forwarded-proto") ??
    (host?.startsWith("localhost") ? "http" : "https");

  return host ? `${proto}://${host}` : "http://localhost:3000";
}
