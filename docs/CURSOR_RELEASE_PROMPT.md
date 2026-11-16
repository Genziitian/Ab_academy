# Prompt: build a new Play Store release of the AB Academy app

Paste everything below the line into the Cursor agent, from the repo root.
Change the first line if you want a specific version.

---

Build a new Google Play release of the AB Academy Android app (Flutter, in
`apps/mobile`). Bump the build number by one; keep the version name unless I
say otherwise.

## Context you must respect

- The app was rejected three times on Play under **Misleading Claims
  (government information)**. Approval depends on these rules. Do not break
  them, and stop and tell me if a requested change would:
  1. Never mention **Bihar Board, BSEB, Bihar School Examination Board**, any
     exam board, official exam dates, results, or any government body, in the
     app UI, the store listing, screenshots or graphics. The app is "for
     Class 12 students", nothing more. (The academy's postal address in
     Mokama, Bihar and the "courts of Bihar" clause in the terms are fine.)
  2. Never add links to government websites (`*.gov.in`) or a
     "not a government app" disclaimer — they are no longer needed and the
     official link failed review as broken.
  3. Never use government emblems, the national flag, Ashoka Chakra, maps of
     India or photos of public figures in the logo, icons or images.
  4. **In-app purchase stays off.** Never pass `--dart-define=IN_APP_PURCHASE=true`
     for a Play build. Play requires Play Billing for digital courses; students
     buy on the website.
- Package name `in.akhandbharatacademy.app` is permanent. Do not change it.
- User-facing name is **AB Academy** (Hindi: AB अकादमी). Do not show
  "Akhand Bharat" anywhere a user can see.

## Steps

1. **Check the working tree.** `git status`. If there are uncommitted changes
   that are not part of this release, stop and ask me.
2. **Scan for forbidden content** and fix or report every hit in user-facing
   text (ignore internal data values like `board: 'Bihar Board'` in mock data
   and mappers, which are never displayed):
   ```bash
   grep -rn -i "bihar board\|bseb\|बिहार बोर्ड\|gov\.in\|akhand bharat\|अखंड" apps/mobile/lib
   ```
3. **Bump the build number** in `apps/mobile/pubspec.yaml`
   (`version: 1.0.0+N` → `1.0.0+N+1`). It must be higher than the last build
   uploaded to Play.
4. **Analyze and test** from `apps/mobile`:
   ```bash
   flutter analyze
   flutter test
   ```
   Both must pass with no issues. If a test fails because of a deliberate text
   change, update the test; otherwise fix the code.
5. **Build the signed bundle** from `apps/mobile`. The Supabase URL and anon key
   are the public `NEXT_PUBLIC_` values in `apps/web/.env.local` (never print
   them, never commit them):
   ```bash
   set -a && . ../web/.env.local && set +a
   flutter build appbundle --release \
     --dart-define=SUPABASE_URL="$NEXT_PUBLIC_SUPABASE_URL" \
     --dart-define=SUPABASE_ANON_KEY="$NEXT_PUBLIC_SUPABASE_ANON_KEY"
   ```
   Signing comes from `apps/mobile/android/key.properties` (git-ignored). If
   that file is missing, stop: an unsigned bundle is rejected by Play.
6. **Verify the bundle** at `apps/mobile/build/app/outputs/bundle/release/app-release.aab`:
   - Signed with the upload key:
     `keytool -printcert -jarfile <aab> | grep SHA1` — must be
     `A1:58:98:52:FF:A1:57:AB:2F:50:59:25:61:68:C3:81:6B:DE:9A:87`.
   - Points at the production backend: unzip `base/lib/arm64-v8a/libapp.so`
     from the bundle and confirm `strings` finds `wjohjdeoitompidjvxgb.supabase.co`.
   - Contains none of the forbidden text:
     `strings libapp.so | grep -i -c "bihar board\|bseb\|biharboardonline"` must be `0`.
   - Version code matches pubspec (check with `bundletool dump manifest` if
     available, otherwise confirm pubspec and the build log).
7. **Copy for upload** to the Desktop folder
   `~/Desktop/AB Academy Play Release (build N)/`:
   - `AB-Academy-buildN.aab`
   - `play-icon-512.png`, `feature-graphic-1024x500.png` and `screenshots/`
     from `apps/mobile/store/`
   - `store-listing-text.txt`: the app name, short and full description from
     the "Store listing text" section of `docs/PLAY_STORE.md`
   - `README.txt` with the Play Console upload steps.
   If the app's screens changed visibly, tell me the screenshots need retaking.
8. **Commit** the version bump and any fixes on the current branch with a clear
   message. Do not commit `.env*`, `key.properties`, keystores, or anything in
   `build/`. Do not push unless I ask.
9. **Report back**: build number, bundle path and size, the verification
   results from step 6, and anything you could not do.

## Do not

- Do not change the Supabase database, storage or Edge Functions.
- Do not upload to Play Console or press "Send for review" — I do that.
- Do not create a new Play developer account or a new package name.
