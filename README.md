# Akhand Bharat Academy

Monorepo for the LMS website, the admin console and the student mobile app.

## Apps

- `apps/web` — Next.js public website + admin console at `/admin`
- `apps/mobile` — Flutter student app (Bihar Board, classes 9–12)
- `supabase` — schema migrations, seed data and the push Edge Function

## Develop

Both apps run with **no configuration at all**, on in-memory mock data. Add the
Supabase env vars and the same code paths read and write the real database.

Website:

```bash
cd apps/web
npm install
npm run dev          # http://localhost:3000
```

Mobile app (needs a simulator or emulator running):

```bash
cd apps/mobile
flutter pub get
flutter run
```

To run either against a real project, see **[docs/RELEASE.md](docs/RELEASE.md)**.

## Current status

### Database — `supabase/migrations`

27 tables with row-level security on every one of them, 62 policies, 4 storage
buckets. Three migrations, applied in order:

1. `20260315000100` — profiles, courses, curriculum, enrolments, orders
2. `20260917000100` — notifications, communities, tickets, lecture discussion
3. `20261006000100` — popups, device tokens, push log, doubt queue, storage
   buckets, **every staff write policy**, and a privilege-escalation fix

> Migration 3 is not optional. Migrations 1 and 2 enable RLS but define
> `select` policies only, so without it every admin write is denied. It also
> closes a hole where a student could set their own `role` to `super_admin`.

### Website + admin console

Real Supabase auth. `/admin` is gated by middleware and by `requireAdmin()`,
and enforced a third time by RLS in Postgres. Ten sections:

| Section | Does |
|---|---|
| Dashboard | live counts across every domain |
| Courses | create, price, publish, assign teachers |
| Students | search, edit class/medium/school, grant course access by hand |
| Content | lessons with YouTube or uploaded video, notes PDFs per lesson |
| Schedule | live classes, mapped onto `live_sessions` |
| Doubts | queue of lecture questions, reply and mark answered |
| Communities | one per course, post and pin announcements, delete messages |
| Tickets | support queue with replies and status |
| Notifications | compose, target, deep link, send as push |
| Popups | scheduled interstitials with targeting and view/click counts |

Teachers (`is_staff`) can manage content, schedule, doubts and communities.
Courses, pricing and enrolments are admin-only (`is_admin`).

### Mobile app

27 screens. Supabase is wired for auth (phone OTP + Google), the catalog,
curriculum, recordings and notes over signed URLs, lecture discussion,
communities with realtime, tickets, notifications and popups. FCM push
registers a device token on launch and claims it at sign-in.

Without `--dart-define` values the app falls back to mock data, so the test
suite and the route-walk harness still run offline.

### Push

`supabase/functions/send-push` resolves a notification's audience, fans out
over FCM HTTP v1, retires tokens FCM rejects and logs to `push_deliveries`.

## Verify

```bash
cd apps/web    && npm run build && npx eslint
cd apps/mobile && flutter analyze && flutter test
```

## Not built yet

- **Payments.** `orders` and `payments` exist with no write policies on
  purpose — they belong to a Razorpay webhook running as the service role,
  which is not written.
- **Lesson progress.** No `lesson_progress` table, so course progress renders
  as 0% rather than a made-up number.
- **Offline downloads.** The app's download screens are still mock.

See **[docs/RELEASE.md](docs/RELEASE.md)** for the step-by-step connect and
ship checklist, and [apps/mobile/README.md](apps/mobile/README.md) for the
app's structure.
