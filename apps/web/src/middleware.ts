import { createServerClient } from "@supabase/ssr";
import { NextResponse, type NextRequest } from "next/server";

/** Student portal routes; signed-out visitors are sent to /login. */
const PORTAL_PREFIXES = [
  "/dashboard",
  "/my-courses",
  "/lecture",
  "/live",
  "/calendar",
  "/materials",
  "/downloads",
  "/notifications",
  "/support",
  "/profile",
  "/checkout",
];

/**
 * Refreshes the Supabase session on every request (tokens are short-lived, and
 * Server Components cannot write cookies), sends signed-out visitors from
 * /admin and the student portal to /login, and blocks /admin for anyone who is
 * not signed-in staff.
 *
 * `requireAdmin()` repeats the role check: middleware runs before the request
 * reaches a page, but RLS in Postgres is the layer that actually protects data.
 */
export async function middleware(request: NextRequest) {
  let response = NextResponse.next({ request });

  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const anonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

  // No project connected: the console runs on mock data in demo mode.
  if (!url || !anonKey) return response;

  const supabase = createServerClient(url, anonKey, {
    cookies: {
      getAll: () => request.cookies.getAll(),
      setAll: (toSet) => {
        toSet.forEach(({ name, value }) => request.cookies.set(name, value));
        response = NextResponse.next({ request });
        toSet.forEach(({ name, value, options }) =>
          response.cookies.set(name, value, options),
        );
      },
    },
  });

  const {
    data: { user },
  } = await supabase.auth.getUser();

  const { pathname } = request.nextUrl;

  const needsLogin =
    pathname.startsWith("/admin") ||
    PORTAL_PREFIXES.some((p) => pathname === p || pathname.startsWith(`${p}/`));

  if (needsLogin && !user) {
    const loginUrl = request.nextUrl.clone();
    loginUrl.pathname = "/login";
    loginUrl.search = "";
    loginUrl.searchParams.set("next", pathname);
    return NextResponse.redirect(loginUrl);
  }

  // Already signed in and visiting /login — staff go to the console, students
  // to their dashboard (or wherever `next` points).
  if (pathname === "/login" && user) {
    const { data: profile } = await supabase
      .from("profiles")
      .select("role")
      .eq("id", user.id)
      .maybeSingle();

    const staff = ["admin", "super_admin", "teacher"].includes(profile?.role ?? "");
    const next = request.nextUrl.searchParams.get("next");
    const safe = next && next.startsWith("/") && !next.startsWith("//") ? next : null;
    const target = request.nextUrl.clone();
    target.pathname = safe ?? (staff ? "/admin" : "/dashboard");
    target.search = "";
    // A student bounced from /admin would loop; send them to the portal.
    if (!staff && target.pathname.startsWith("/admin")) target.pathname = "/dashboard";
    return NextResponse.redirect(target);
  }

  return response;
}

export const config = {
  matcher: [
    // Everything except static assets and image files.
    "/((?!_next/static|_next/image|favicon.ico|images/|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)",
  ],
};
