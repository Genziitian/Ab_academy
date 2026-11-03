-- Migration 16: free notes library.
--
-- Subject → chapter → notes, managed in Admin → Free notes and shown on the
-- website's /notes page. Free notes are public on purpose, so each one is
-- simply a Google Drive file id that the page embeds in Drive's viewer.
-- Anyone can read published rows; only staff can write.

create table if not exists public.free_note_subjects (
  id uuid primary key default gen_random_uuid(),
  name text not null check (length(trim(name)) > 0),
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.free_note_chapters (
  id uuid primary key default gen_random_uuid(),
  subject_id uuid not null references public.free_note_subjects (id) on delete cascade,
  title text not null check (length(trim(title)) > 0),
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.free_notes (
  id uuid primary key default gen_random_uuid(),
  chapter_id uuid not null references public.free_note_chapters (id) on delete cascade,
  title text not null check (length(trim(title)) > 0),
  drive_file_id text not null check (drive_file_id ~ '^[A-Za-z0-9_-]{10,}$'),
  is_published boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

create index if not exists free_note_chapters_subject_idx on public.free_note_chapters (subject_id, sort_order);
create index if not exists free_notes_chapter_idx on public.free_notes (chapter_id, sort_order);

alter table public.free_note_subjects enable row level security;
alter table public.free_note_chapters enable row level security;
alter table public.free_notes enable row level security;

drop policy if exists "free_note_subjects_read" on public.free_note_subjects;
create policy "free_note_subjects_read" on public.free_note_subjects for select using (true);
drop policy if exists "free_note_subjects_staff_write" on public.free_note_subjects;
create policy "free_note_subjects_staff_write" on public.free_note_subjects
  for all using (public.is_staff()) with check (public.is_staff());

drop policy if exists "free_note_chapters_read" on public.free_note_chapters;
create policy "free_note_chapters_read" on public.free_note_chapters for select using (true);
drop policy if exists "free_note_chapters_staff_write" on public.free_note_chapters;
create policy "free_note_chapters_staff_write" on public.free_note_chapters
  for all using (public.is_staff()) with check (public.is_staff());

drop policy if exists "free_notes_read" on public.free_notes;
create policy "free_notes_read" on public.free_notes
  for select using (is_published or public.is_staff());
drop policy if exists "free_notes_staff_write" on public.free_notes;
create policy "free_notes_staff_write" on public.free_notes
  for all using (public.is_staff()) with check (public.is_staff());

grant select on public.free_note_subjects, public.free_note_chapters, public.free_notes to anon, authenticated;
grant insert, update, delete on public.free_note_subjects, public.free_note_chapters, public.free_notes to authenticated;
