import { NextResponse, type NextRequest } from "next/server";
import { createServerClient } from "@/lib/supabase/server";

export async function POST(request: NextRequest) {
  const supabase = await createServerClient();
  if (supabase) await supabase.auth.signOut();
  // 303 so the browser follows with a GET rather than re-POSTing to /login.
  return NextResponse.redirect(`${request.nextUrl.origin}/login`, 303);
}
