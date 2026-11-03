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
