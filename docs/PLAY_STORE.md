# Google Play submission checklist

Checked against Google Play policy on 3 November 2026. Policies change —
re-read the linked pages before each submission.

## Must fix before submitting

### 1. Selling courses inside the app (Payments policy) — **highest risk**

Courses are digital content used inside the app, so Google Play's Payments
policy applies: in-app purchases must go through **Google Play Billing**.
The app currently sells through **Razorpay** only.

For users in India, Google lets developers offer an **alternative billing
system alongside Play Billing** ("user choice billing"), with a reduced Play
service fee on alternative transactions. To keep Razorpay you must:

1. Enrol in the India alternative billing programme in Play Console.
2. Integrate Play Billing as well, and show the Play-required choice screen.
3. Report each Razorpay transaction to Google through the Play Developer API.

The other compliant option is to **not sell in the app**: remove checkout
from the app and let students buy on the website only, without in-app links
or prompts to buy elsewhere. Pick one before the first upload.

- [Understanding Google Play's Payments policy](https://support.google.com/googleplay/android-developer/answer/10281818)
- [Alternative billing systems (users)](https://support.google.com/googleplay/answer/11174377)

### 2. Target API level — done in code

New apps and updates must target **Android 16 (API 36)** from 31 August 2026.
`android/app/build.gradle.kts` now sets `compileSdk = 36` and
`targetSdk = 36`. Test on an Android 16 device or emulator before upload:
Android 16 always draws apps edge to edge.

- [Target API level requirements](https://developer.android.com/google/play/requirements/target-sdk)

## Store listing text (build 7)

Rejected three times under Misleading Claims. The first two times for
mentioning Bihar Board / BSEB without an official source link; the third
time because that link (biharboardonline.bihar.gov.in) does not load for
Google's reviewers. Fix in build 7: **the app and the listing no longer
mention any board, exam body or government at all** — the app is simply for
Class 12 students. With no government information there is nothing to source.
Keep it that way: do not add "Bihar Board", "BSEB", official exam dates or
.gov links to the app, the listing, screenshots or graphics.

**App name (max 30):**

```
AB Academy: Class 12 Science
```

**Short description (max 80):**

```
Class 12 Physics, Chemistry & Maths crash course in Hindi and Hinglish.
```

**Full description:**

```
Class 12 Physics, Chemistry and Maths — planned chapter by chapter. AB Academy is a crash course for Class 12 science students, taught by Ajit Sir in Hindi or Hinglish — you choose the language you understand best.

WHAT YOU GET
• Recorded lecture for every chapter — watch at your own pace, as many times as you need
• A practice session for every chapter with exam-style questions written by our teachers
• Live doubt classes with Ajit Sir
• Chapter notes and solved practice questions, opening right inside the app
• A free demo course to try the classroom before you start

COURSES
• Class 12 Physics Crash Course — 14 chapters
• Class 12 Chemistry Crash Course — 10 chapters
• Class 12 Maths Crash Course — 13 chapters

BUILT FOR CLASS 12 STUDENTS
• Taught in Hindi and Hinglish
• Simple, clean app that works well on everyday phones
• Sign in with your Google account — your courses appear automatically

HELP WHEN YOU NEED IT
Raise a support ticket from the app and our team replies inside the app. You can also write to support@abacademy.in.

YOUR PRIVACY
We collect only what is needed to run your account and classes. We never sell your data and the app shows no ads. You can delete your account and data from the app at any time (More → Data & Account Deletion).

Website: https://abacademy.in
Privacy policy: https://abacademy.in/privacy
```

### Resubmission checklist (build 7)

Files are in `apps/mobile/store/`.

1. **Backend — done 13 Nov 2026:** the Free Demo Course thumbnail and the
   "Start learning free" home slide now use `launch/feature-notes.jpg`
   instead of `launch/demo-yt.jpg`, which showed the IIT Madras emblem.
2. **App bundle:** upload `apps/mobile/build/app/outputs/bundle/release/app-release.aab`
   (version 1.0.0, build 7) to the production track, replacing earlier builds.
3. **Store listing:** app icon `play-icon-512.png`; feature graphic
   `feature-graphic-1024x500.png`; delete every old screenshot and upload
   `screenshots/*.png`.
4. **Text:** name, short and full description from the section above.
5. **App content:** if asked whether the app is a government app, answer no.
6. **Publishing overview → Send changes for review**, then confirm nothing is
   left under "Not yet submitted".

## Done in this release

| Requirement | Where |
|---|---|
| In-app account deletion | App → More → Account → **Delete account or data** |
| Web account deletion (no reinstall needed) | `https://<your-domain>/data-deletion` — sign in and request, or email |
| Deletion actually deletes (not deactivate) | `process_deletion_request()` removes the sign-in and personal data; super admin completes within 3 days at Admin → **Deletion requests** |
| Privacy policy, in app and on the web | `/privacy`, App → More → Privacy Policy |
| Terms, refund policy | `/terms`, `/refund`, also in App → More |
| Screenshots of paid content blocked | `FLAG_SECURE` on lecture and notes screens |
| No backup of app data | `allowBackup="false"` + data extraction rules |
| Minimal permissions | `INTERNET` and `POST_NOTIFICATIONS` only |

## Play Console forms

**Privacy policy URL:** `https://<your-domain>/privacy`

**Account deletion URL (Data safety → Data deletion):** `https://<your-domain>/data-deletion`

**Data safety** — data collected (none sold, none used for ads; all encrypted
in transit; users can request deletion):

| Data type | Collected | Why |
|---|---|---|
| Name, email address | Yes (Google sign-in) | Account management |
| Phone number | Yes (OTP sign-in) | Account management |
| Photos (profile photo from Google) | Yes | Account management |
| Purchase history | Yes | App functionality |
| Other user-generated content (doubts, comments, tickets) | Yes | App functionality |
| App interactions (lectures and notes opened) | Yes | App functionality |
| Device or other IDs (push token) | Yes | App functionality (notifications) |
| Financial info (card / UPI) | **No** — handled by Razorpay, never reaches us |

Shared with: none for advertising. Service providers (Supabase, Razorpay,
Google/Firebase, YouTube) process data on our behalf, which Play does not
count as "sharing".

**Target audience and content:** students of Class 11–12 are mostly 15–17.
Choose age groups **16–17** and **18+** (add 13–15 only if younger students
will use it). Because minors are included, the app must not show ads or use
analytics SDKs that profile users — it does neither today. If you ever pick an
age group under 13, the stricter Families policy applies.

**Content rating:** fill the IARC questionnaire — education, user-generated
content: **yes** (doubts and comments under lectures).

**User-generated content policy:** students post doubts and comments, so the
app needs (a) terms that forbid objectionable content — in `/terms`; (b) a way
for users to report content or users — today that is Help & support; a
**"Report" action on each comment** is recommended; (c) moderation — staff
review doubts in Admin → Doubts and can remove posts.

**App access for review:** reviewers cannot receive your OTP. Give them a test
login in Play Console → App access: a Supabase test phone number with a fixed
OTP (Authentication → Providers → Phone → Test phone numbers), enrolled in a
course so the reviewer can open lectures and notes.

**Store listing:** app name, short and full description, 512 px icon, feature
graphic 1024×500, at least 2 phone screenshots. The banners in
`apps/web/public/images/brand/` can be cropped for the feature graphic. Do not
claim results ("100% marks") you cannot back up.

**Signing:** enrol in Play App Signing, then add the **app signing key SHA-1**
from Play Console to the Google Cloud OAuth Android client, or Google sign-in
fails for Play-installed copies.
