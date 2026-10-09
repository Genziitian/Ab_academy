// Supabase Edge Function: fan a notification row out to FCM device tokens.
//
// Deploy:  supabase functions deploy send-push
// Secrets: supabase secrets set FCM_PROJECT_ID=... FCM_CLIENT_EMAIL=... FCM_PRIVATE_KEY=...
//
// Called by the admin console after it inserts into `notifications`. It runs
// with the service-role key, so it can read every device token regardless of
// RLS — which is exactly why this logic lives here and not in the client.

import { createClient } from "jsr:@supabase/supabase-js@2";

type Payload = { notification_id: string };

const FCM_SCOPE = "https://www.googleapis.com/auth/firebase.messaging";

/**
 * Mints an OAuth2 access token from the service-account key. FCM's legacy
 * server key is deprecated, so HTTP v1 + a signed JWT is the supported path.
 */
async function getAccessToken(): Promise<string> {
  const clientEmail = Deno.env.get("FCM_CLIENT_EMAIL")!;
  const rawKey = Deno.env.get("FCM_PRIVATE_KEY")!.replace(/\\n/g, "\n");

  const pem = rawKey
    .replace(/-----BEGIN PRIVATE KEY-----/, "")
    .replace(/-----END PRIVATE KEY-----/, "")
    .replace(/\s/g, "");
  const der = Uint8Array.from(atob(pem), (c) => c.charCodeAt(0));

  const key = await crypto.subtle.importKey(
    "pkcs8",
    der,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );

  const now = Math.floor(Date.now() / 1000);
  const header = { alg: "RS256", typ: "JWT" };
  const claims = {
    iss: clientEmail,
    scope: FCM_SCOPE,
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  };

  const b64 = (obj: unknown) =>
    btoa(JSON.stringify(obj)).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");

  const unsigned = `${b64(header)}.${b64(claims)}`;
  const sig = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(unsigned),
  );
  const sigB64 = btoa(String.fromCharCode(...new Uint8Array(sig)))
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/, "");

  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: `${unsigned}.${sigB64}`,
    }),
  });

  if (!res.ok) throw new Error(`token: ${await res.text()}`);
  return (await res.json()).access_token;
}

Deno.serve(async (req) => {
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  let notificationId = "";

  try {
    const { notification_id } = (await req.json()) as Payload;
    notificationId = notification_id;

    const { data: note, error: noteErr } = await supabase
      .from("notifications")
      .select("*")
      .eq("id", notification_id)
      .single();
    if (noteErr) throw noteErr;

    // Resolve the audience to a set of student ids, mirroring the RLS policy
    // on `notifications`.
    let studentIds: string[] | null = null;

    if (note.audience === "student") {
      studentIds = [note.audience_student_id];
    } else if (note.audience === "class") {
      const { data } = await supabase
        .from("student_profiles")
        .select("user_id")
        .eq("class_level", note.audience_class);
      studentIds = (data ?? []).map((r) => r.user_id);
    } else if (note.audience === "course") {
      const { data } = await supabase
        .from("enrollments")
        .select("student_id")
        .eq("course_id", note.audience_course_id)
        .eq("status", "active");
      studentIds = (data ?? []).map((r) => r.student_id);
    }
    // audience = 'all' leaves studentIds null, meaning every active token.

    let tokenQuery = supabase
      .from("device_tokens")
      .select("token")
      .eq("is_active", true);

    if (studentIds !== null) {
      if (studentIds.length === 0) {
        await supabase
          .from("push_deliveries")
          .update({
            status: "sent",
            recipients: 0,
            completed_at: new Date().toISOString(),
          })
          .eq("notification_id", notification_id);
        return Response.json({ ok: true, recipients: 0 });
      }
      tokenQuery = tokenQuery.in("user_id", studentIds);
    }

    const { data: tokenRows, error: tokenErr } = await tokenQuery;
    if (tokenErr) throw tokenErr;

    const tokens = (tokenRows ?? []).map((r) => r.token);
    if (tokens.length === 0) {
      await supabase
        .from("push_deliveries")
        .update({
          status: "sent",
          recipients: 0,
          completed_at: new Date().toISOString(),
        })
        .eq("notification_id", notification_id);
      return Response.json({ ok: true, recipients: 0 });
    }

    const accessToken = await getAccessToken();
    const projectId = Deno.env.get("FCM_PROJECT_ID")!;
    const endpoint = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;

    let delivered = 0;
    let failed = 0;
    const staleTokens: string[] = [];

    // FCM v1 has no multicast endpoint, so send per token in bounded batches.
    const BATCH = 50;
    for (let i = 0; i < tokens.length; i += BATCH) {
      const slice = tokens.slice(i, i + BATCH);

      const results = await Promise.allSettled(
        slice.map((token) =>
          fetch(endpoint, {
            method: "POST",
            headers: {
              Authorization: `Bearer ${accessToken}`,
              "Content-Type": "application/json",
            },
            body: JSON.stringify({
              message: {
                token,
                notification: { title: note.title, body: note.body },
                data: {
                  notification_id: note.id,
                  deep_link: note.deep_link ?? "",
                },
                android: { priority: "high" },
                apns: {
                  payload: { aps: { sound: "default", badge: 1 } },
                },
              },
            }),
          }).then(async (res) => {
            if (res.ok) return { token, ok: true };
            const text = await res.text();
            // 404 UNREGISTERED / 400 INVALID_ARGUMENT mean the install is gone.
            if (res.status === 404 || text.includes("UNREGISTERED")) {
              staleTokens.push(token);
            }
            throw new Error(text);
          }),
        ),
      );

      for (const r of results) {
        if (r.status === "fulfilled") delivered++;
        else failed++;
      }
    }

    // Retire tokens FCM rejected, so they are not retried forever.
    if (staleTokens.length > 0) {
      await supabase
        .from("device_tokens")
        .update({ is_active: false })
        .in("token", staleTokens);
    }

    await supabase
      .from("push_deliveries")
      .update({
        status: failed === tokens.length ? "failed" : "sent",
        recipients: tokens.length,
        delivered,
        failed,
        completed_at: new Date().toISOString(),
      })
      .eq("notification_id", notification_id);

    return Response.json({ ok: true, recipients: tokens.length, delivered, failed });
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);

    if (notificationId) {
      await supabase
        .from("push_deliveries")
        .update({
          status: "failed",
          error: message,
          completed_at: new Date().toISOString(),
        })
        .eq("notification_id", notificationId);
    }

    return Response.json({ ok: false, error: message }, { status: 500 });
  }
});
