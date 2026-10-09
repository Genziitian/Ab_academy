import { cookies } from "next/headers";
import { createServerClient as createSSRClient } from "@supabase/ssr";
import type { SupabaseClient } from "@supabase/supabase-js";

export function hasSupabaseEnv() {
  return Boolean(
    process.env.NEXT_PUBLIC_SUPABASE_URL &&
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY,
  );
}

/**
 * Request-scoped client that reads the caller's session from cookies, so RLS
 * applies as that user. Use this for anything a signed-in person does.
 */
export async function createServerClient(): Promise<SupabaseClient | null> {
  if (!hasSupabaseEnv()) return null;
  const cookieStore = await cookies();

  return createSSRClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll: () => cookieStore.getAll(),
        setAll: (toSet) => {
          // Server Components cannot set cookies; middleware refreshes the
          // session instead, so a failure here is expected and harmless.
          try {
            toSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options),
            );
          } catch {
            /* called from a Server Component — ignore */
          }
        },
      },
    },
  );
}

/**
 * Service-role client: bypasses RLS entirely. Only for work no user initiates
 * (push fan-out, payment webhooks). Never import this into a Client Component.
 */
export function createServiceClient(): SupabaseClient | null {
  const key = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!process.env.NEXT_PUBLIC_SUPABASE_URL || !key) return null;

  return createSSRClient(process.env.NEXT_PUBLIC_SUPABASE_URL, key, {
    cookies: { getAll: () => [], setAll: () => {} },
  });
}
