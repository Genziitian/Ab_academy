# Slice 2 — Supabase foundation

## What was added

- `supabase/migrations/20260315000100_init_schema.sql` — core LMS schema + RLS
- `supabase/seed.sql` — Bihar Board sample catalog
- `supabase/config.toml` — local Supabase defaults
- `.env.example` — env keys for the web app

## Apply to a Supabase project

1. Create a project at https://supabase.com
2. Install CLI: `npm i -g supabase` (or use npx)
3. From repo root:

```bash
npx supabase login
npx supabase link --project-ref YOUR_PROJECT_REF
npx supabase db push
npx supabase db query --file supabase/seed.sql
```

Or paste the migration + seed SQL into the Supabase SQL editor.

4. Copy `.env.example` → `apps/web/.env.local` and fill URL + anon key.

## Website behaviour

- If `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY` are set, `/courses` and `/course/[slug]` load published courses from Supabase.
- If env is missing, the app falls back to local mock catalog so the marketing site still works.
