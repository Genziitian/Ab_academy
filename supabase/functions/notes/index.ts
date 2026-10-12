// Supabase Edge Function: stream a class-notes PDF to the app.
//
// Deploy:  supabase functions deploy notes
// Secrets (optional, for private Drive files):
//   supabase secrets set GOOGLE_SA_EMAIL=...@....iam.gserviceaccount.com \
//                        GOOGLE_SA_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n..."
//
// GET /functions/v1/notes?id=<lesson_resources.id>   (student's bearer token)
//
// The app never learns where a note lives. This function asks
// `note_access()` — as the student, so enrolment rules apply — for the
// note's source, fetches the PDF server-side and returns only the bytes:
//
//   source = 'storage' → the private `lesson-notes` bucket.
//   source = 'gdrive'  → Google Drive. With a service account configured the
//       file can stay private (share the notes folder with the service
//       account's email as Viewer). Without one the file must be shared as
//       "Anyone with the link"; the link still never reaches students.

import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;
const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const SA_EMAIL = Deno.env.get("GOOGLE_SA_EMAIL") ?? "";
const SA_KEY = (Deno.env.get("GOOGLE_SA_PRIVATE_KEY") ?? "").replace(/\\n/g, "\n");

const MAX_BYTES = 60 * 1024 * 1024;

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const fail = (message: string, status: number) =>
  new Response(JSON.stringify({ error: message }), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });

const b64url = (bytes: Uint8Array | string) => {
  const raw = typeof bytes === "string" ? bytes : String.fromCharCode(...bytes);
  return btoa(raw).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
};

/** OAuth token for the Drive API from the service-account key. */
async function driveToken(): Promise<string> {
  const pem = SA_KEY.replace(/-----(BEGIN|END) PRIVATE KEY-----/g, "").replace(/\s/g, "");
  const der = Uint8Array.from(atob(pem), (c) => c.charCodeAt(0));
  const key = await crypto.subtle.importKey(
    "pkcs8",
    der,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const now = Math.floor(Date.now() / 1000);
  const unsigned =
    `${b64url(JSON.stringify({ alg: "RS256", typ: "JWT" }))}.` +
    b64url(
      JSON.stringify({
        iss: SA_EMAIL,
        scope: "https://www.googleapis.com/auth/drive.readonly",
        aud: "https://oauth2.googleapis.com/token",
        iat: now,
        exp: now + 3600,
      }),
    );
  const sig = new Uint8Array(
    await crypto.subtle.sign("RSASSA-PKCS1-v1_5", key, new TextEncoder().encode(unsigned)),
  );
  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: `${unsigned}.${b64url(sig)}`,
    }),
  });
  const body = await res.json();
  if (!res.ok) throw new Error("Drive sign-in failed.");
  return body.access_token as string;
}

async function fromDrive(fileId: string): Promise<Uint8Array> {
  const res = SA_EMAIL && SA_KEY
    ? await fetch(
        `https://www.googleapis.com/drive/v3/files/${encodeURIComponent(fileId)}?alt=media&supportsAllDrives=true`,
        { headers: { Authorization: `Bearer ${await driveToken()}` } },
      )
    : await fetch(
        `https://drive.google.com/uc?export=download&id=${encodeURIComponent(fileId)}`,
        { redirect: "follow" },
      );
  if (!res.ok) throw new Error(`Drive returned ${res.status}.`);
  return new Uint8Array(await res.arrayBuffer());
}

async function fromStorage(path: string): Promise<Uint8Array> {
  const admin = createClient(SUPABASE_URL, SERVICE_KEY, { auth: { persistSession: false } });
  const { data, error } = await admin.storage.from("lesson-notes").download(path);
  if (error || !data) throw new Error("Notes file is missing.");
  return new Uint8Array(await data.arrayBuffer());
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });

  const id = new URL(req.url).searchParams.get("id") ?? "";
  if (!/^[0-9a-f-]{36}$/i.test(id)) return fail("Missing note id.", 400);

  const auth = req.headers.get("Authorization") ?? "";
  if (!auth.startsWith("Bearer ")) return fail("Sign in to read notes.", 401);

  // Runs as the student: note_access() applies the enrolment rules.
  const asStudent = createClient(SUPABASE_URL, ANON_KEY, {
    global: { headers: { Authorization: auth } },
    auth: { persistSession: false },
  });
  const { data, error } = await asStudent.rpc("note_access", { p_resource_id: id });
  if (error) {
    return error.code === "42501"
      ? fail("Enroll in this course to read these notes.", 403)
      : fail("Could not open these notes.", 500);
  }
  const note = (data as Array<Record<string, string | null>> | null)?.[0];
  if (!note) return fail("These notes no longer exist.", 404);

  let bytes: Uint8Array;
  try {
    bytes = note.source === "gdrive"
      ? await fromDrive(note.drive_file_id ?? "")
      : await fromStorage(note.storage_path ?? "");
  } catch (e) {
    console.error("notes fetch failed", id, e instanceof Error ? e.message : e);
    return fail("Could not load these notes. Please try again.", 502);
  }

  // Drive answers non-shared or oversized files with an HTML page, not a PDF.
  const isPdf = bytes.length > 4 && new TextDecoder().decode(bytes.slice(0, 5)) === "%PDF-";
  if (!isPdf) {
    console.error("notes source is not a PDF", id);
    return fail("These notes are not available right now.", 502);
  }
  if (bytes.length > MAX_BYTES) return fail("These notes are too large to open.", 413);

  return new Response(bytes, {
    headers: {
      ...cors,
      // The app's Supabase client hands back raw bytes only for
      // octet-stream; it would decode application/pdf as text.
      "Content-Type": "application/octet-stream",
      // Nothing between the app and here should keep a copy.
      "Cache-Control": "private, no-store",
    },
  });
});
