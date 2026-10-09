-- Akhand Bharat Academy — Slice 4: popups, push delivery, doubt queue,
-- storage buckets, and the staff write policies the admin console needs.
--
-- Applied on top of:
--   20260315000100_init_schema.sql
--   20260917000100_community_notifications_tickets.sql
--
-- Why this migration exists: slices 2 and 3 created every table with RLS
-- enabled but defined SELECT policies only. Under RLS a missing policy denies,
-- so *every* admin write (create a course, schedule a class, reply to a
-- ticket) would fail. The second half of this file closes that hole.

-- ================================================================ enums

create type public.popup_placement as enum ('app_launch', 'home', 'course');
create type public.push_status as enum ('queued', 'sent', 'failed');

-- =============================================================== popups

-- Interstitial cards the app shows on launch / home / a course screen.
-- Audience targeting mirrors `notifications` so the admin UI can share code.
create table public.popups (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  body text not null default '',
  image_path text,
  cta_label text,
  cta_url text,
  placement public.popup_placement not null default 'app_launch',
  audience public.notification_audience not null default 'all',
  audience_class smallint check (audience_class between 9 and 12),
  audience_course_id uuid references public.courses (id) on delete cascade,
  audience_student_id uuid references public.profiles (id) on delete cascade,
  -- A popup is live when is_active and now() falls inside the window.
  is_active boolean not null default true,
  starts_at timestamptz not null default now(),
  ends_at timestamptz,
  -- 0 = show every launch; N = stop after the student has seen it N times.
  max_views_per_student smallint not null default 1 check (max_views_per_student >= 0),
  priority smallint not null default 0,
  created_by uuid references public.profiles (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint popups_audience_target check (
    (audience = 'all' and audience_class is null and audience_course_id is null and audience_student_id is null)
    or (audience = 'class' and audience_class is not null)
    or (audience = 'course' and audience_course_id is not null)
    or (audience = 'student' and audience_student_id is not null)
  ),
  constraint popups_window check (ends_at is null or ends_at > starts_at),
  -- A CTA needs both halves or neither.
  constraint popups_cta_pair check ((cta_label is null) = (cta_url is null))
);

-- One row per student per popup, counting impressions and recording a dismiss.
create table public.popup_views (
  popup_id uuid not null references public.popups (id) on delete cascade,
  student_id uuid not null references public.profiles (id) on delete cascade,
  view_count integer not null default 1,
  dismissed_at timestamptz,
  clicked_at timestamptz,
  last_seen_at timestamptz not null default now(),
  primary key (popup_id, student_id)
);

create index popups_live_idx on public.popups (is_active, starts_at, ends_at);
create index popups_priority_idx on public.popups (priority desc, created_at desc);

create trigger popups_updated_at
before update on public.popups
for each row execute function public.set_updated_at();

-- ========================================================= push delivery

-- One row per installed app instance. `user_id` is null between app launch
-- and sign-in, so a token is claimed on login rather than created there.
create table public.device_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles (id) on delete cascade,
  token text not null unique,
  platform text not null check (platform in ('android', 'ios', 'web')),
  app_version text,
  is_active boolean not null default true,
  last_seen_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create index device_tokens_user_idx on public.device_tokens (user_id) where is_active;

-- Delivery log: the admin console writes a notification, the Edge Function
-- fans it out to tokens and writes the outcome back here.
create table public.push_deliveries (
  id uuid primary key default gen_random_uuid(),
  notification_id uuid not null references public.notifications (id) on delete cascade,
  status public.push_status not null default 'queued',
  recipients integer not null default 0,
  delivered integer not null default 0,
  failed integer not null default 0,
  error text,
  created_at timestamptz not null default now(),
  completed_at timestamptz
);

create index push_deliveries_notification_idx on public.push_deliveries (notification_id);

-- Richer payloads than slice 3's title/body pair.
alter table public.notifications add column if not exists image_path text;
alter table public.notifications add column if not exists deep_link text;
alter table public.notifications add column if not exists send_push boolean not null default true;

-- ========================================================== doubt queue

-- Slice 3 modelled lecture discussion as a flat comment thread. The admin
-- console needs it to behave as a work queue, so a comment can be marked
-- answered and attributed.
alter table public.lesson_comments add column if not exists is_doubt boolean not null default false;
alter table public.lesson_comments add column if not exists is_resolved boolean not null default false;
alter table public.lesson_comments add column if not exists resolved_by uuid references public.profiles (id) on delete set null;
alter table public.lesson_comments add column if not exists resolved_at timestamptz;

create index lesson_comments_doubt_queue_idx
on public.lesson_comments (is_resolved, created_at desc)
where is_doubt;

-- ===================================================== recordings/notes

-- Slice 2 gave lessons a bare `video_ref`. Real playback needs to know where
-- the file lives and whether it is ready.
alter table public.lessons add column if not exists storage_path text;
alter table public.lessons add column if not exists thumbnail_path text;
alter table public.lessons add column if not exists is_downloadable boolean not null default false;
alter table public.lesson_resources add column if not exists size_bytes bigint;
alter table public.lesson_resources add column if not exists is_downloadable boolean not null default true;

-- A recording produced by a finished live class becomes a lesson.
alter table public.live_sessions add column if not exists recording_lesson_id uuid references public.lessons (id) on delete set null;

-- ====================================================== RLS for new tables

alter table public.popups enable row level security;
alter table public.popup_views enable row level security;
alter table public.device_tokens enable row level security;
alter table public.push_deliveries enable row level security;

-- Students see only live popups aimed at them; staff see all of them.
create policy "popups_read_targeted"
on public.popups for select
using (
  public.is_staff()
  or (
    is_active = true
    and starts_at <= now()
    and (ends_at is null or ends_at > now())
    and (
      audience = 'all'
      or (audience = 'student' and audience_student_id = auth.uid())
      or (
        audience = 'class'
        and exists (
          select 1 from public.student_profiles sp
          where sp.user_id = auth.uid()
            and sp.class_level = public.popups.audience_class
        )
      )
      or (
        audience = 'course'
        and exists (
          select 1 from public.enrollments e
          where e.student_id = auth.uid()
            and e.course_id = public.popups.audience_course_id
            and e.status = 'active'
        )
      )
    )
  )
);

create policy "popups_staff_write"
on public.popups for all
using (public.is_staff())
with check (public.is_staff());

create policy "popup_views_own"
on public.popup_views for all
using (student_id = auth.uid() or public.is_staff())
with check (student_id = auth.uid());

-- A device token belongs to whoever claimed it. Unclaimed rows (user_id null)
-- are insert-only from the client and never readable back.
create policy "device_tokens_own_read"
on public.device_tokens for select
using (user_id = auth.uid() or public.is_staff());

create policy "device_tokens_insert"
on public.device_tokens for insert
with check (user_id is null or user_id = auth.uid());

create policy "device_tokens_own_update"
on public.device_tokens for update
using (user_id = auth.uid() or public.is_staff())
with check (user_id = auth.uid() or public.is_staff());

create policy "device_tokens_own_delete"
on public.device_tokens for delete
using (user_id = auth.uid() or public.is_staff());

create policy "push_deliveries_staff_only"
on public.push_deliveries for all
using (public.is_staff())
with check (public.is_staff());

-- ============================================ staff writes on slice 2/3

-- `is_staff()` includes teachers. Course and pricing changes are restricted
-- further to admins, so a teacher cannot republish or reprice a course.
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles p
    where p.id = auth.uid()
      and p.role in ('admin', 'super_admin')
  );
$$;

create policy "courses_admin_write"
on public.courses for all
using (public.is_admin())
with check (public.is_admin());

create policy "teachers_admin_write"
on public.teachers for all
using (public.is_admin())
with check (public.is_admin());

create policy "course_teachers_admin_write"
on public.course_teachers for all
using (public.is_admin())
with check (public.is_admin());

-- Curriculum structure and content: any staff member, teachers included.
create policy "batches_staff_write"
on public.course_batches for all
using (public.is_staff())
with check (public.is_staff());

create policy "subjects_staff_write"
on public.subjects for all
using (public.is_staff())
with check (public.is_staff());

create policy "chapters_staff_write"
on public.chapters for all
using (public.is_staff())
with check (public.is_staff());

create policy "lessons_staff_write"
on public.lessons for all
using (public.is_staff())
with check (public.is_staff());

create policy "lesson_resources_staff_write"
on public.lesson_resources for all
using (public.is_staff())
with check (public.is_staff());

-- MISSING READ POLICY.
--
-- Slice 2 enabled RLS on lesson_resources but never gave it a select policy,
-- so a student could not list the notes attached to a lesson at all — the
-- app's Notes tab would come back empty. Access follows the lesson: a free
-- preview is open, anything else needs an active enrolment.
create policy "lesson_resources_read"
on public.lesson_resources for select
using (
  public.is_staff()
  or exists (
    select 1
    from public.lessons l
    where l.id = public.lesson_resources.lesson_id
      and l.is_published = true
      and (
        l.is_demo = true
        or exists (
          select 1
          from public.chapters ch
          join public.subjects s on s.id = ch.subject_id
          join public.course_batches b on b.id = s.batch_id
          join public.enrollments e on e.batch_id = b.id
          where ch.id = l.chapter_id
            and e.student_id = auth.uid()
            and e.status = 'active'
        )
      )
  )
);

create policy "live_sessions_staff_write"
on public.live_sessions for all
using (public.is_staff())
with check (public.is_staff());

-- Manual enrolment (offline payment, comped access) from the students page.
create policy "enrollments_admin_write"
on public.enrollments for all
using (public.is_admin())
with check (public.is_admin());

-- Staff edit student records; `profiles_update_own` already covers self-edit.
create policy "profiles_admin_update"
on public.profiles for update
using (public.is_admin())
with check (public.is_admin());

-- PRIVILEGE ESCALATION FIX.
--
-- Slice 2 wrote `profiles_update_own` as `using (auth.uid() = id)` with no
-- WITH CHECK clause. That lets a student update their own row *including the
-- role column*, so any signed-in student could run
--
--     update profiles set role = 'super_admin' where id = auth.uid();
--
-- and then read and write every table in the schema. RLS cannot express
-- "this column may not change" — a policy sees only the new row — so the rule
-- is enforced with a trigger instead.
--
-- auth.uid() is null for the service role and for direct psql, which are
-- already trusted and bypass RLS; those paths stay open so the first admin can
-- be promoted by hand (see docs/RELEASE.md step 4).
create or replace function public.protect_profile_role()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.role is distinct from old.role
     and auth.uid() is not null
     and not public.is_admin() then
    raise exception 'Only an admin can change a profile role'
      using errcode = '42501';
  end if;
  return new;
end;
$$;

create trigger profiles_protect_role
before update on public.profiles
for each row execute function public.protect_profile_role();

create policy "student_profiles_staff_write"
on public.student_profiles for all
using (public.is_staff())
with check (public.is_staff());

-- Communities: staff create them and post pinned announcements.
create policy "communities_staff_write"
on public.communities for all
using (public.is_staff())
with check (public.is_staff());

create policy "community_members_staff_write"
on public.community_members for all
using (public.is_staff())
with check (public.is_staff());

-- Slice 3 let a member insert only as themselves, which blocks staff
-- announcements. Widen insert and allow staff to delete a message.
drop policy if exists "community_messages_member_write" on public.community_messages;
create policy "community_messages_write"
on public.community_messages for insert
with check (
  public.is_staff()
  or (
    author_id = auth.uid()
    and exists (
      select 1 from public.community_members m
      where m.community_id = public.community_messages.community_id
        and m.student_id = auth.uid()
    )
  )
);

create policy "community_messages_staff_delete"
on public.community_messages for delete
using (public.is_staff());

-- Staff close or reassign a ticket; students can no longer flip their own
-- status (slice 3's `tickets_staff_update` allowed it).
drop policy if exists "tickets_staff_update" on public.tickets;
create policy "tickets_staff_update"
on public.tickets for update
using (public.is_staff())
with check (public.is_staff());

create policy "lesson_comments_staff_delete"
on public.lesson_comments for delete
using (public.is_staff());

-- =============================================================== storage

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('lesson-notes',  'lesson-notes',  false, 52428800,   array['application/pdf']),
  ('lesson-videos', 'lesson-videos', false, 2147483648, array['video/mp4', 'video/webm', 'application/x-mpegURL']),
  ('popup-images',  'popup-images',  true,  5242880,    array['image/png', 'image/jpeg', 'image/webp']),
  ('course-thumbnails', 'course-thumbnails', true, 5242880, array['image/png', 'image/jpeg', 'image/webp'])
on conflict (id) do nothing;

-- Private buckets: staff write; enrolled students read via signed URLs
-- minted server-side, so no student-facing select policy is needed here.
create policy "lesson_notes_staff_all"
on storage.objects for all
to authenticated
using (bucket_id = 'lesson-notes' and public.is_staff())
with check (bucket_id = 'lesson-notes' and public.is_staff());

create policy "lesson_videos_staff_all"
on storage.objects for all
to authenticated
using (bucket_id = 'lesson-videos' and public.is_staff())
with check (bucket_id = 'lesson-videos' and public.is_staff());

-- Public buckets: anyone reads, staff writes.
create policy "public_images_read"
on storage.objects for select
using (bucket_id in ('popup-images', 'course-thumbnails'));

create policy "public_images_staff_write"
on storage.objects for all
to authenticated
using (bucket_id in ('popup-images', 'course-thumbnails') and public.is_staff())
with check (bucket_id in ('popup-images', 'course-thumbnails') and public.is_staff());

-- ============================================================== realtime

alter publication supabase_realtime add table public.popups;
