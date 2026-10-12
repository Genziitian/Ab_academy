# Release checklist

Everything here is required before the first production deploy and the first
Play Store upload. Steps are in dependency order — each one assumes the ones
above it are done.

---

## 1. Create the Supabase project

1. <https://supabase.com/dashboard> → **New project**. Pick the Mumbai
   (`ap-south-1`) region — the students are in Bihar, and this is the single
   biggest latency win available.
2. Save the database password somewhere durable. It cannot be recovered.
3. **Project Settings → API** gives you three values:

   | Value | Where it goes |
   |---|---|
   | Project URL | `NEXT_PUBLIC_SUPABASE_URL` |
   | `anon` public key | `NEXT_PUBLIC_SUPABASE_ANON_KEY` |
   | `service_role` secret key | `SUPABASE_SERVICE_ROLE_KEY` (server only) |

> The `service_role` key bypasses every RLS policy. It must never appear in
> the Flutter app, in a `NEXT_PUBLIC_*` variable, or in a client bundle.



## 2. Apply the schema

Install the CLI (`brew install supabase/tap/supabase`), then:

```bash
supabase link --project-ref YOUR_PROJECT_REF
supabase db push
```

That applies every migration in order:

| Migration | Contents |
|---|---|
| `20260315000100_init_schema.sql` | profiles, courses, curriculum, enrolments, orders |
| `20260917000100_community_notifications_tickets.sql` | notifications, communities, tickets, lecture discussion |
| `20261006000100_popups_push_and_admin_writes.sql` | popups, device tokens, push log, doubt queue, storage buckets, **all staff write policies** |
| `20261009000100_profile_email_on_signup.sql` | copies the sign-in email onto the profile |
| `20261012000100_course_banners_and_checkout.sql` | app course slider, Razorpay order columns |
| `20261013000100_protect_lesson_video_refs.sql` | hides video ids from students; `lesson_playback()` |
| `20261014000100_drive_notes.sql` | notes from Google Drive; `note_access()` |
| `20261015000100_codes_and_transactions.sql` | random course and student codes, super-admin-only transactions |
| `20261015000200_seed_catalog_and_demo_lectures.sql` | the six crash courses, demo lectures and notes |
| `20261015000300_fix_protect_codes.sql` | fix for the code-lock trigger in the migration above |

Prefer the dashboard? Paste each file into **SQL Editor** in that order.

Verify afterwards that every migration shows on both sides:

```bash
supabase migration list
```

> **Why the third migration matters.** The first two enable RLS on every table
> but define `select` policies only. Under RLS a missing policy denies, so
> without migration 3 every admin write fails. Do not skip it.

## 3. The launch catalog

Migration `20261015000200` already creates the six crash courses (the same
catalog as the website), one batch each, and free demo lessons in Class 11
and Class 12 Science → Mathematics: four Gen-Z IITian lectures on YouTube and
two notes PDFs on Google Drive. It uses fixed ids and `on conflict do
nothing`, so it never overwrites edits made in the console.

## 4. Create your first admin

Signing up always creates a `student` — by design, since the role column is
what the RLS policies trust. Promote yourself by hand, once:

1. **Authentication → Users → Add user**, with an email and password.
2. **SQL Editor**:

```sql
update public.profiles
set role = 'super_admin', email = 'you@akhandbharatacademy.in'
where id = 'THE-USER-UUID-FROM-STEP-1';
```

Roles:

| Role | Can |
|---|---|
| `super_admin` | everything, plus **Transactions** (order log, revenue analytics, CSV export) and granting or removing `super_admin` |
| `admin` | the whole console except Transactions; can promote students to `teacher` or `admin` |
| `teacher` | content, schedule and doubts; not courses, pricing or enrolments |

The checks are in Postgres, not just the console: `is_super_admin()` guards
the `orders`/`payments` read policies and the role trigger (migration
`20261015000100`); `is_admin()` vs `is_staff()` guard everything else.

Live project: `backup.sriram.mail@gmail.com` is the super admin and
`abacademy@gmail.com` is an admin (email + password sign-in).

### Course and student codes

Every course gets a random `course_code` (`ABA-C-7K3Q9X`) and every account a
random `student_code` (`ABA-S-4MZT8KQ2`) from the database. Both are unique
and locked by a trigger, so nobody can change one, not even an admin. Codes
show in the console's Courses and Students pages, on transactions, and as
**Student ID** in the app's Profile.

## 5. Turn on auth providers

**Authentication → Providers**:

- **Phone** — students sign in with an OTP. Needs an SMS provider; Twilio or
  MSG91 both work, and MSG91 is usually cheaper for Indian numbers.
- **Email** — staff sign-in for the admin console.
- **Google** (optional) — add the OAuth client, then add both redirect URLs
  under **URL Configuration → Redirect URLs**:
  - `https://YOUR_DOMAIN/auth/callback`
  - `in.akhandbharatacademy.app://login-callback`

## 6. Storage

Migration 3 creates all four buckets. Confirm under **Storage**:

| Bucket | Public | Limit | Holds |
|---|---|---|---|
| `lesson-videos` | no | 2 GB | uploaded recordings |
| `lesson-notes` | no | 50 MB | notes PDFs |
| `popup-images` | yes | 5 MB | popup artwork |
| `course-thumbnails` | yes | 5 MB | course cards |

Private buckets are read through short-lived signed URLs minted server-side,
so a student cannot share a permanent link to a paid recording.

## 7. Push notifications

1. Create a Firebase project and add an Android app with package name
   **`in.akhandbharatacademy.app`**.
2. Download `google-services.json` → `apps/mobile/android/app/`.
3. For iOS, add an iOS app, download `GoogleService-Info.plist` →
   `apps/mobile/ios/Runner/`, and upload your APNs key under
   **Project Settings → Cloud Messaging**.
4. **Project Settings → Service accounts → Generate new private key**. From
   that JSON:

```bash
supabase secrets set \
  FCM_PROJECT_ID=your-firebase-project-id \
  FCM_CLIENT_EMAIL=firebase-adminsdk-xxx@your-project.iam.gserviceaccount.com \
  FCM_PRIVATE_KEY="$(jq -r .private_key service-account.json)"

supabase functions deploy send-push
```

The admin console calls `send-push` after writing a notification. It resolves
the audience, fans out over FCM HTTP v1, deactivates tokens FCM rejects, and
logs the result to `push_deliveries`. If it fails, the in-app notification
still lands — only the push is lost.

## 8. Deploy the website

Vercel, root directory `apps/web`. Set in **Settings → Environment Variables**:

```
NEXT_PUBLIC_SUPABASE_URL
NEXT_PUBLIC_SUPABASE_ANON_KEY
SUPABASE_SERVICE_ROLE_KEY
```

With these set, `/admin` requires a signed-in staff account and the demo
banner disappears. Without them the site still builds and serves the catalog
from mock data.

## 9. Build the mobile app

### Signing key (once, and never lose it)

```bash
keytool -genkey -v -keystore ~/aba-upload.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Then `apps/mobile/android/key.properties` — gitignored, never committed:

```properties
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=/Users/you/aba-upload.jks
```

> Losing this file means you can never update the app under the same listing.
> Back it up somewhere you will still have in five years. Enrolling in Play App
> Signing gives Google a recoverable copy — worth doing.

Without `key.properties` the release build is **unsigned** rather than
debug-signed. That is deliberate: a debug-signed bundle is rejected at upload,
and failing at build time is better than failing in the Play Console.

### Build

```bash
cd apps/mobile
flutter build appbundle --release \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

Google sign-in needs no define: it opens an external browser and returns
through the `in.akhandbharatacademy.app://login-callback` deep link, so the
Google client id lives only in the Supabase dashboard. That redirect must be
listed under Authentication -> URL Configuration -> Redirect URLs.

Output: `build/app/outputs/bundle/release/app-release.aab`.

Omit the `--dart-define`s and the app runs on mock data — useful for a demo
build, never for the store.

## 10. Play Store listing

- **Package name**: `in.akhandbharatacademy.app` (permanent once uploaded)
- **Icon**: `apps/mobile/store/play-icon-512.png`
- **Privacy policy**: `https://YOUR_DOMAIN/privacy` — mandatory
- **Data safety**: declare what the app actually collects — name, phone
  number, email, and the FCM token. All of it is tied to the account and
  encrypted in transit.
- **Content rating**: complete the IARC questionnaire; this app rates Everyone.
- **Target audience**: if you declare under-13s, Families Policy applies and
  brings extra requirements. Classes 9–12 is normally 13+.

Version bumps go in `apps/mobile/pubspec.yaml` (`version: 1.0.0+1` →
`1.0.1+2`). The build number must increase on every upload.

---

## Verifying a connected setup

```bash
# Web: admin requires auth, catalog reads live data
cd apps/web && npm run build && npm start

# Mobile: analyzer, tests, release bundle
cd apps/mobile && flutter analyze && flutter test
```

Then in the console: create a course → it appears on `/courses` and in the
app; send a notification → it reaches a device with the app installed; upload
a notes PDF → it opens in the app's PDF viewer.

## Selling courses (Razorpay)

Apply migration `20261012000100_course_banners_and_checkout.sql`, then deploy
the checkout function and give it your Razorpay keys:

```bash
supabase functions deploy checkout --no-verify-jwt
supabase secrets set RAZORPAY_KEY_ID=rzp_live_... RAZORPAY_KEY_SECRET=... \
                     RAZORPAY_WEBHOOK_SECRET=...
```

In the Razorpay dashboard add a webhook to
`https://YOUR_PROJECT.supabase.co/functions/v1/checkout` for the
`payment.captured` event, using the same webhook secret. It enrols students
whose app closed before the payment was verified.

Without keys the function refuses to sell. For a staging project only, set
`ALLOW_TEST_CHECKOUT=true` to let "Pay" enrol without charging.

## Lecture videos (YouTube)

Lectures play from YouTube inside the app's own player
(`lib/widgets/secure_youtube_player.dart`). For each lecture:

- Upload to YouTube as **Unlisted** (not Private — private videos cannot be
  embedded) and leave **Allow embedding** on.
- In the admin console, set the lesson's provider to YouTube and paste only
  the 11-character video id.

Apply migration `20261013000100_protect_lesson_video_refs.sql`. After it,
students cannot read `lessons.video_ref` directly; the app asks
`lesson_playback(lesson_id)` at play time, which answers only for published
demo lessons or students with an active enrolment.

Screenshots and screen recording are blocked on Android while a lecture is on
screen. For QA screenshots only, build with
`--dart-define=ALLOW_SCREENSHOTS=true`.

## Class notes (Google Drive)

Notes open in the app's PDF viewer (`lib/screens/lessons/pdf_viewer_screen.dart`)
and are never saved to the phone. The app asks the `notes` Edge Function for a
note by id; the function checks access with `note_access()` (migration 7),
fetches the PDF from Google Drive or the private `lesson-notes` bucket, and
streams only the bytes. The Drive link never reaches students.

To add notes: Admin → Content → a lesson → paste the Google Drive link of the
PDF (or upload a PDF) → Attach PDF.

Drive sharing, pick one:

- **Simple:** share each PDF as "Anyone with the link — Viewer".
- **Private (recommended):** create a Google Cloud service account with the
  Drive API enabled, share the notes folder with the service account's email
  as Viewer, and give the function its key:

  ```bash
  supabase secrets set GOOGLE_SA_EMAIL=notes@PROJECT.iam.gserviceaccount.com \
                       GOOGLE_SA_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
  ```

Deploy or redeploy the function with `supabase functions deploy notes`.
