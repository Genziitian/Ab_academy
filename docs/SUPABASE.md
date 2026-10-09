# Supabase setup

## The one file to run

`supabase/setup.sql` is the whole database — catalog, identity, enrolment,
payments, notifications, communities, tickets, and lecture discussion/feedback,
with RLS and realtime configured. It is the consolidation of both migration
files and is **idempotent**, so running it twice is harmless.

1. Create a project at https://supabase.com
2. Dashboard → **SQL Editor** → New query → paste `supabase/setup.sql` → **Run**
3. Optionally paste `supabase/seed.sql` and run it for sample courses
   (also safe to re-run)

Or from the command line, if you have `psql`:

```bash
psql "$DATABASE_URL" -f supabase/setup.sql
psql "$DATABASE_URL" -f supabase/seed.sql
```

### Using the CLI instead

`supabase/migrations/` holds the same schema split into two ordered migrations.
Use these if you want migration history rather than a one-shot script:

```bash
npx supabase login
npx supabase link --project-ref YOUR_PROJECT_REF
npx supabase db push
```

Run **either** `setup.sql` **or** `db push` — not both on the same project. They
describe the same schema; applying one after the other is redundant (though the
idempotent guards mean it will not break anything).

## After the schema is in

1. **Connect the apps.** Copy `.env.example` → `apps/web/.env.local` and fill in
   the project URL and anon key from Dashboard → Settings → API. Without these
   the website silently serves the mock catalog in `apps/web/src/lib/courses.ts`.

2. **Enable Google sign-in.** Dashboard → Authentication → Providers → Google.
   Paste the client ID and secret from a Google Cloud OAuth client, and add the
   callback URL Supabase shows you to that client's authorised redirect URIs.
   `handle_new_user()` already handles OAuth signups — it reads `email`,
   `full_name`/`name` and `avatar_url`/`picture`, and does not assume a phone
   number is present.

3. **Make yourself an admin.** Sign in once so your row exists, then:

   ```sql
   update public.profiles set role = 'super_admin' where email = 'you@example.com';
   ```

   `is_staff()` drives every admin-side RLS policy, and the `/admin` console will
   check it once its auth is wired.

## What the triggers do for you

- **A community per course.** Inserting a course creates its community row.
- **Auto-join on enrolment.** Inserting an enrolment adds the student to that
  course's community. Neither app manages membership; it follows enrolment.
- **Profile on signup.** A new `auth.users` row creates `profiles` and
  `student_profiles` rows.

`setup.sql` also backfills communities and memberships for any courses and
enrolments that already exist.

## Realtime

`notifications`, `community_messages` and `ticket_messages` are added to the
`supabase_realtime` publication, which is what the mobile app subscribes to for
live notification and chat updates.

## Still to wire

The schema is ready but neither app talks to it yet. The mobile app runs on
`apps/mobile/lib/data/mock/mock_data.dart`, and the `/admin` console runs on
`apps/web/src/lib/admin/mock-store.ts` and is **not access-controlled** —
`requireAdmin()` in `apps/web/src/lib/admin/auth.ts` returns a stub user. Do not
deploy the admin console publicly until that is replaced with a real session and
`is_staff()` check.
