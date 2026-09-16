# Akhand Bharat Academy

Monorepo for the LMS website (Flutter later).

## Apps

- `apps/web` — Next.js public website + (later) student LMS

## Develop

```bash
cd apps/web
npm install
npm run dev
```

Open [http://localhost:3000](http://localhost:3000).

## Current status

- Marketing pages with AI hero/feature images
- Mobile sticky **Explore Courses** CTA
- Copy framed as Akhand Bharat Academy (Bihar Board first; more domains soon)
- Slice 2: Supabase migrations + seed + catalog wiring (falls back to mock without env)

See [docs/SUPABASE.md](docs/SUPABASE.md) to connect a project.
