import { NextResponse, type NextRequest } from "next/server";
import { createServerClient } from "@/lib/supabase/server";

export async function POST(request: NextRequest) {
  const supabase = await createServerClient();
  if (supabase) await supabase.auth.signOut();
  return NextResponse.redirect(`${request.nextUrl.origin}/login`);
}
