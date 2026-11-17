# Prompt: hand-off to a Claude agent (VS Code / Cursor extension)

Paste everything below the line as the first message to the agent, opened at
the repo root. Add your actual request at the very end.

---

You are taking over the **AB Academy** project. Read this whole message before
doing anything. It records what went wrong over two weeks of Google Play
rejections, so you do not repeat any of it.

## The project

- Monorepo. `apps/mobile` = Flutter Android app (package
  `in.akhandbharatacademy.app`, permanent — never change it). `apps/web` =
  Next.js website + admin console. `supabase/` = database migrations and Edge
  Functions (project ref `wjohjdeoitompidjvxgb`).
- Product: Class 12 Physics, Chemistry and Maths crash courses taught by Ajit
  Sir in Hindi/Hinglish. Recorded lectures (YouTube), live doubt classes,
  chapter notes (Google Drive PDFs), support tickets, lecture discussions.
- User-facing name: **AB Academy** (Hindi: AB अकादमी). Never show
  "Akhand Bharat" to users. Internal identifiers (package name, Dart package
  `akhand_bharat_academy`, class `AkhandBharatAcademyApp`) stay as they are.
- Git remote that matters: `abacademy` → `github.com/Genziitian/Ab_academy`.
  Working branch `redesign-calm-bilingual`; `main` is production.
- **Pushing to `main` deploys the live website automatically**: Hostinger
  rebuilds `abacademy.in` from `main`, and Vercel deploys
  `web-two-sand-99.vercel.app`. Never push to `main` without being asked, and
  run `npm run build` in `apps/web` first — a broken build breaks the live site.
- Secrets live only in git-ignored files: `apps/web/.env.local`, `.envv2`
  (repo root, includes the Play reviewer demo login `DEMO_EMAIL` /
  `DEMO_PASSWORD`), `apps/mobile/android/key.properties` (upload keystore).
  Never print, commit or send their values anywhere.

## What went wrong before (do not repeat)

1. **Rejection 1 & 2 — Misleading Claims: "Missing Source Link for Government
   Information".** The store description and app said "Bihar Board (BSEB)",
   "follows the BSEB syllabus" with no disclaimer and no official link. The
   logo was a round seal with the tricolour India map, two **Ashoka Chakras**
   (part of the State Emblem) and portraits of Dr. Kalam and Swami
   Vivekananda — it looked like a government seal. The demo course thumbnail
   showed the **IIT Madras emblem** (a government institute).
2. **Rejection 3 — "Broken or Inaccessible Source Link".** The fix added the
   official link `https://biharboardonline.bihar.gov.in`. That site does not
   load for Google's reviewers (TLS connection reset). Adding .gov links was
   the wrong strategy.
3. **Final fix (build 8): remove the government information entirely.** No
   board name, no exam body, no official exam dates, no .gov links, no
   "not a government app" disclaimer — anywhere (app, store listing,
   screenshots, feature graphic, website). The app is simply "for Class 12
   students". Logo replaced with a neutral "AB / ACADEMY" monogram.
4. **Problems found in the full audit (also fixed in build 8):**
   - Razorpay SDK was bundled though in-app purchase is off → it added NFC
     and READ_BASIC_PHONE_STATE permissions with no visible use and a Data
     safety mismatch. The SDK was removed from the app.
   - Students' lecture comments had **no Report action** (required by Play's
     User Generated Content policy). Added; covered by
     `apps/mobile/test/report_comment_test.dart`.
   - The demo course showed a **seeded ★ 4.9 rating** with no real reviews
     (misleading). Ratings are hidden in the app until real.
   - Copy like "Board-ready in 60 days" read as a promised result. Neutralised.
   - Store screenshots had an **alpha channel** (Play requires 24-bit PNG/JPEG).
   - Store icon in `apps/mobile/store/` was still the old seal.
5. **Process mistakes to avoid:**
   - The old description was still what Google reviewed because the new
     listing was left under "Not yet submitted". Always confirm the changes
     were actually sent for review.
   - The website build on `main` was broken by unfinished portal files that
     imported missing modules; they now live in `wip/portal/`. Do not move
     them back into `apps/web/src` until they compile.
   - Screenshots taken from **mock data** would show fake teachers, Commerce
     courses and prices — misrepresentation. Take screenshots against the real
     backend (debug build + demo quick login), never from mock data.
   - Build numbers: Play refuses any build number already uploaded. Always
     bump `version: 1.0.0+N` in `apps/mobile/pubspec.yaml`.
   - Do not suggest a new Play developer account to escape rejections: that is
     ban evasion and can terminate both accounts.

## Rules that keep the app approved

- No Bihar Board / BSEB / बिहार बोर्ड / exam-board names, official exam dates,
  results or `*.gov.in` links in anything a user or reviewer sees. (The
  academy's postal address in Mokama, Bihar and the "courts of Bihar" clause in
  the terms are fine.)
- No government emblems, national flag, Ashoka Chakra, India maps or photos of
  public figures in logos, icons, thumbnails or banners — including images
  stored in the database (course thumbnails, home slides).
- No fake ratings, review counts, "guaranteed marks", "topper", "No. 1",
  "board-ready" style claims.
- In-app purchase stays off for Play (`IN_APP_PURCHASE` dart-define never set
  to true) and no payment SDK is bundled. Students buy on the website; the app
  must not link or prompt users to pay elsewhere.
- Every post by another student keeps its Report action.
- Allowed Android permissions (merged release manifest): INTERNET,
  ACCESS_NETWORK_STATE, POST_NOTIFICATIONS, VIBRATE, WAKE_LOCK, Firebase
  c2dm RECEIVE, DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION, USE_BIOMETRIC,
  USE_FINGERPRINT (from androidx.biometric). Anything new must be explained
  to the owner before release.
- Account deletion stays available in the app (More → Delete account or data)
  and on the web (`/data-deletion`).

## How to build and verify a release

The full step-by-step is in `docs/CURSOR_RELEASE_PROMPT.md`; store listing
text and the Play checklist are in `docs/PLAY_STORE.md`. In short:

1. Scan: `grep -rn -i "bihar board\|bseb\|बिहार बोर्ड\|gov\.in\|akhand bharat\|अखंड" apps/mobile/lib apps/web/src` → no user-facing hits.
2. Bump the build number; `flutter analyze` and `flutter test` must pass.
3. Build from `apps/mobile` with the public Supabase values from
   `apps/web/.env.local`:
   `flutter build appbundle --release --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
4. Verify: upload-key SHA1 `A1:58:98:52:FF:A1:57:AB:2F:50:59:25:61:68:C3:81:6B:DE:9A:87`;
   `libapp.so` contains the Supabase project ref and 0 forbidden strings;
   permissions as listed above; `unzip -l <aab> | grep -ic razorpay` is 0.
5. Store assets in `apps/mobile/store/`: icon 512×512 32-bit PNG, feature
   graphic 1024×500 without alpha, phone screenshots 24-bit PNG with the long
   side at most 2× the short side.
6. Copy the bundle and assets to `~/Desktop/AB Academy Play Release (build N)/`.

Play Console steps (the owner does these, not you): upload the bundle,
replace all screenshots, paste the listing text, fill **App access** with the
demo email login ("Sign in with email" on the login screen), Data safety
(Financial info: not collected), then **Send changes for review** and confirm
nothing is left under "Not yet submitted".

## Still open (not blocking Play)

- Migration `supabase/migrations/20261111000100_security_hardening.sql` is
  **not applied** to the live database, and the `checkout` / `send-push` Edge
  Function changes are not deployed. Until then the website's Razorpay refund
  webhook fails (it calls `revoke_refunded_order`). Ask before touching the
  live database.
- Demo course content: one worksheet PDF is from Vanier College (their name is
  printed on it); the demo videos are IIT Madras BS-degree lectures from the
  owner's Gen-Z IITian channel, not Class 12 content. Replace with Class 12
  material when available.
- Course rows in the database still store `board = 'Bihar Board'` and some
  highlights say "Board-pattern questions". The app and website no longer
  display the board field; leave the data unless asked.

## How to work with the owner

- Do not change the live database, storage or Edge Functions, push to `main`,
  or upload anything to Play without explicit permission in this chat.
- Verify before claiming: run the build, the tests, and check the live pages
  with `curl` after a deploy. Report failures plainly.
- Keep explanations short and concrete; the owner has lost two weeks to
  rejections and wants it right the first time.

My request:
