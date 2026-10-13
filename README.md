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

Row-level security on every table. Ten migrations, applied in order (the full
list is in `docs/RELEASE.md` step 2):

1. `20260315000100` — profiles, courses, curriculum, enrolments, orders
2. `20260917000100` — notifications, communities, tickets, lecture discussion
3. `20261006000100` — popups, device tokens, push log, doubt queue, storage
   buckets, **every staff write policy**, and a privilege-escalation fix
4. `20261009000100` → `20261014000100` — profile email, app slider, Razorpay
   orders, hidden video ids, Google Drive notes
5. `20261015000100` → `20261015000300` — random course and student codes,
   super-admin-only transactions, and the launch catalog with demo lectures

> Migration 3 is not optional. Migrations 1 and 2 enable RLS but define
> `select` policies only, so without it every admin write is denied. It also
> closes a hole where a student could set their own `role` to `super_admin`.

### Website + admin console

The public site (Home, Courses, Course page, Notes, For Students, About,
Contact, Privacy, Terms) and a student portal (Dashboard, My Courses, Lecture,
Live Classes, Live Classroom, Calendar, Study Materials, Downloads,
Notifications, Help & Support, Profile, Checkout) follow the 2026 redesign in
`EdTech Platform Website Redesign/`. Portal pages require sign-in when Supabase
is configured; their course, schedule and notes content is still sample data
(`apps/web/src/lib/portal/data.ts`) until it is wired to enrolments.

Real Supabase auth. `/admin` is gated by middleware and by `requireAdmin()`,
and enforced a third time by RLS in Postgres. Eleven sections:

| Section | Does |
|---|---|
| Dashboard | live counts across every domain |
| Courses | create, edit, price, publish, assign teachers; shows each course's random code |
| Students | search (also by student code), edit class/medium/school, grant course access by hand |
| Content | lessons with YouTube or uploaded video, notes PDFs per lesson |
| Schedule | live classes, mapped onto `live_sessions` |
| Doubts | queue of lecture questions, reply and mark answered |
| Tickets | support queue with replies and status |
| Notifications | compose, target, deep link, send as push |
| Popups | scheduled interstitials with targeting and view/click counts |
| App slider | course slides for the app's Home and Courses store — artwork, link, order, schedule |
| Transactions | **super admin only** — every checkout with its Razorpay payments, revenue by day and by course, conversion, CSV export |

Teachers (`is_staff`) can manage content, schedule and doubts.
Courses, pricing and enrolments are admin-only (`is_admin`).

### Mobile app

Bottom tabs: **Home** (promotional slider, next live class, quick actions,
courses, announcements), **Courses** (My courses with search, and Explore —
the store, sold through Razorpay via the `checkout` Edge Function), a raised
**Academics** button (calendar, live sessions, class notes, support,
downloads, announcements), **Updates** (announcements and notifications) and
**More** (profile, settings, support, policies, sign out). The community
feature was removed; students ask doubts under each lecture.

Live on Supabase: Google sign-in (native, in-app), the catalog, My courses
with chapter / lecture / notes counts, the course page and curriculum, the
secure YouTube player, Drive notes in the in-app viewer, live sessions,
**announcements** (Notifications in the console, with read state and
realtime refresh) and **support tickets** (raised in the app, answered from
the console's Tickets page; the student gets a notification and the open
thread refreshes). A saved session skips the login screen on launch.

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
