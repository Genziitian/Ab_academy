# Akhand Bharat Academy — mobile app

Flutter app for Bihar Board students (classes 9–12), built from the 20-screen design in
`Mobile app design question/Bihar Board App.dc.html`.

## Run

```bash
cd apps/mobile
flutter pub get
flutter run
```

Needs an iOS simulator or Android emulator running (`flutter emulators --launch <id>`).

## Current status

All 27 screens are built and navigable on **mock data** — there are no network calls yet.
Actions that would need a backend (downloads, payment, sending a message upstream) show a
snackbar instead. The PDF viewer is real — it reads a bundled asset.

- **Onboarding** — splash → login (mobile number) → OTP (custom keypad, live resend countdown)
  → class picker → stream + medium picker
- **Sign-in options** — phone OTP, "Continue with Google", and a "Quick login (skip OTP)"
  shortcut. Google and quick login both sign the demo student straight in; both are stubs
  awaiting real auth (`_googleLogin` / `_quickLogin` in
  `lib/screens/onboarding/login_screen.dart`)
- **Simulated realtime** — a notification arrives a few seconds after Home opens, standing in for
  the Supabase realtime subscription (`realtimeNotificationProvider`)
- **Core tabs** — Home, Courses, Live, Community, Profile (bottom nav, per-tab state)
- **Course** — details (Overview / Curriculum / Videos / Notes / Tests) → curriculum accordion or
  video library → **Lecture** (player, Discussion, Notes with an in-app PDF viewer, Feedback)
- **Live** — happening now / upcoming / past recordings → lobby (countdown) → classroom
- **Community** — one group per enrolled course, auto-joined, with pinned announcements
- **Tickets** — list, detail with replies, and a new-ticket form (under Profile → Support)
- **Pushed screens** — calendar, downloads, study materials, notifications,
  purchase → checkout → payment success

## Verifying

```bash
flutter analyze
flutter test
```

`test/screen_smoke_test.dart` walks all 20 routes and fails on structural layout errors. It runs
on a surface wider than the 390pt design on purpose: widget tests substitute a font whose glyphs
are full em squares, so text measures about twice as wide as Plus Jakarta Sans and reports
overflows the design does not have on a device.

Overflow at the real width is therefore checked by running the app with real fonts:

```bash
flutter run -d chrome -t lib/main_route_walk.dart --web-browser-flag="--window-size=390,844"
```

That harness steps through every route and prints `ROUTEWALK-ERROR` / `ROUTEWALK-DONE … errors=N`.
It is a dev tool, not part of the shipped app.

## Structure

| Path | What's in it |
| --- | --- |
| `lib/theme/` | Design tokens — colours, type scale, radii, shadows |
| `lib/data/models/` | Domain models, shaped after the Supabase schema in `supabase/migrations/` |
| `lib/data/mock/` | Seed data reproducing the design's content |
| `lib/data/providers/` | Riverpod providers for session, onboarding and per-screen UI state |
| `lib/widgets/` | Shared components from the design's component sheet |
| `lib/screens/` | One folder per section, one file per screen |
| `lib/router/` | go_router config — `StatefulShellRoute` for the five tabs |

## Next slice

Swap `lib/data/mock/mock_data.dart` for Supabase queries. The schema is already written:
`supabase/migrations/20260315000100_init_schema.sql` plus
`20260917000100_community_notifications_tickets.sql`, which adds notifications, communities
(created per course and auto-joined on enrolment by trigger), tickets, and lecture
comments/feedback. That pass also brings real Google + phone auth and Razorpay checkout.
