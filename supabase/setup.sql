-- =====================================================================
-- Akhand Bharat Academy — complete database setup
-- =====================================================================
-- Run this ONCE against a Supabase project to bring it fully up to date.
-- It is the consolidation of:
--   migrations/20260315000100_init_schema.sql          (catalog + identity)
--   migrations/20260917000100_community_notifications_tickets.sql
--   migrations/20261006000100_popups_push_and_admin_writes.sql
--
-- Safe to re-run: every statement is idempotent, so running it twice
-- changes nothing the second time. Paste it into the Supabase SQL editor
-- (Dashboard → SQL Editor → New query → Run), or:
--   psql "$DATABASE_URL" -f supabase/setup.sql
--
-- It does NOT insert sample courses. For that, run supabase/seed.sql after.
-- =====================================================================

create extension if not exists "pgcrypto";

-- ---------------------------------------------------------------------
-- 1. Enum types
-- ---------------------------------------------------------------------
-- Postgres has no CREATE TYPE IF NOT EXISTS, so each one is guarded.

do $$
begin
  if not exists (select 1 from pg_type where typname = 'user_role') then
    create type public.user_role as enum ('student', 'teacher', 'admin', 'super_admin');
  end if;
  if not exists (select 1 from pg_type where typname = 'lesson_type') then
    create type public.lesson_type as enum ('LIVE', 'VIDEO', 'PDF', 'TEST', 'ASSIGNMENT');
  end if;
  if not exists (select 1 from pg_type where typname = 'live_provider') then
    create type public.live_provider as enum ('youtube', 'jitsi');
  end if;
  if not exists (select 1 from pg_type where typname = 'live_status') then
    create type public.live_status as enum (
      'SCHEDULED', 'LIVE', 'ENDED', 'RECORDING_PROCESSING', 'RECORDING_AVAILABLE'
    );
  end if;
  if not exists (select 1 from pg_type where typname = 'enrollment_status') then
    create type public.enrollment_status as enum ('active', 'expired', 'cancelled', 'refunded');
  end if;
  if not exists (select 1 from pg_type where typname = 'order_status') then
    create type public.order_status as enum ('created', 'pending', 'paid', 'failed', 'refunded');
  end if;
  if not exists (select 1 from pg_type where typname = 'notification_audience') then
    create type public.notification_audience as enum ('all', 'class', 'course', 'student');
  end if;
  if not exists (select 1 from pg_type where typname = 'ticket_status') then
    create type public.ticket_status as enum ('open', 'in_progress', 'resolved', 'closed');
  end if;
  if not exists (select 1 from pg_type where typname = 'ticket_category') then
    create type public.ticket_category as enum
      ('payment', 'content', 'technical', 'account', 'other');
  end if;
end
$$;

-- ---------------------------------------------------------------------
-- 2. Identity
-- ---------------------------------------------------------------------

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  phone text unique,
  full_name text,
  avatar_url text,
  role public.user_role not null default 'student',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Added for OAuth signups, which arrive with an email rather than a phone.
alter table public.profiles add column if not exists email text;
create unique index if not exists profiles_email_idx
  on public.profiles (email) where email is not null;

create table if not exists public.student_profiles (
  user_id uuid primary key references public.profiles (id) on delete cascade,
  class_level smallint check (class_level between 9 and 12),
  board text default 'Bihar Board',
  medium text check (medium in ('Hindi', 'English')),
  stream text,
  school text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.teachers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid unique references public.profiles (id) on delete set null,
  display_name text not null,
  bio text,
  avatar_url text,
  subjects text[] default '{}',
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- 3. Catalog
-- ---------------------------------------------------------------------

create table if not exists public.courses (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  title text not null,
  description text not null default '',
  board text not null default 'Bihar Board',
  class_level smallint not null check (class_level between 9 and 12),
  language text not null default 'Hindi',
  thumbnail_url text,
  thumbnail_hue integer not null default 214,
  price_inr integer not null check (price_inr >= 0),
  original_price_inr integer,
  rating numeric(2,1) not null default 0,
  lessons_count integer not null default 0,
  highlights text[] not null default '{}',
  subjects text[] not null default '{}',
  is_published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.course_batches (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references public.courses (id) on delete cascade,
  name text not null,
  starts_on date,
  ends_on date,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.subjects (
  id uuid primary key default gen_random_uuid(),
  batch_id uuid not null references public.course_batches (id) on delete cascade,
  name text not null,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.chapters (
  id uuid primary key default gen_random_uuid(),
  subject_id uuid not null references public.subjects (id) on delete cascade,
  title text not null,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.lessons (
  id uuid primary key default gen_random_uuid(),
  chapter_id uuid not null references public.chapters (id) on delete cascade,
  title text not null,
  lesson_type public.lesson_type not null default 'VIDEO',
  sort_order integer not null default 0,
  duration_seconds integer,
  video_provider text,
  video_ref text,
  is_demo boolean not null default false,
  is_published boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.lesson_resources (
  id uuid primary key default gen_random_uuid(),
  lesson_id uuid not null references public.lessons (id) on delete cascade,
  title text not null,
  resource_type text not null default 'PDF',
  storage_path text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.course_teachers (
  course_id uuid not null references public.courses (id) on delete cascade,
  teacher_id uuid not null references public.teachers (id) on delete cascade,
  is_primary boolean not null default false,
  primary key (course_id, teacher_id)
);

create table if not exists public.live_sessions (
  id uuid primary key default gen_random_uuid(),
  batch_id uuid not null references public.course_batches (id) on delete cascade,
  subject_id uuid references public.subjects (id) on delete set null,
  chapter_id uuid references public.chapters (id) on delete set null,
  teacher_id uuid references public.teachers (id) on delete set null,
  title text not null,
  description text,
  starts_at timestamptz not null,
  ends_at timestamptz,
  provider public.live_provider not null default 'youtube',
  youtube_video_id text,
  jitsi_room_id text,
  status public.live_status not null default 'SCHEDULED',
  recording_url text,
  created_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- 4. Enrolment and payments
-- ---------------------------------------------------------------------

create table if not exists public.enrollments (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.profiles (id) on delete cascade,
  course_id uuid not null references public.courses (id) on delete cascade,
  batch_id uuid references public.course_batches (id) on delete set null,
  status public.enrollment_status not null default 'active',
  purchased_at timestamptz not null default now(),
  expires_at timestamptz,
  unique (student_id, course_id)
);

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.profiles (id) on delete cascade,
  course_id uuid not null references public.courses (id) on delete restrict,
  amount_inr integer not null,
  currency text not null default 'INR',
  status public.order_status not null default 'created',
  razorpay_order_id text unique,
  coupon_code text,
  created_at timestamptz not null default now()
);

create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  razorpay_payment_id text unique,
  amount_inr integer not null,
  status text not null,
  raw_payload jsonb,
  created_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- 5. Notifications
-- ---------------------------------------------------------------------

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  body text not null,
  audience public.notification_audience not null default 'all',
  -- Exactly one target is set, matching `audience`; all null means everyone.
  audience_class smallint check (audience_class between 9 and 12),
  audience_course_id uuid references public.courses (id) on delete cascade,
  audience_student_id uuid references public.profiles (id) on delete cascade,
  created_by uuid references public.profiles (id) on delete set null,
  sent_at timestamptz not null default now(),
  constraint notifications_audience_target check (
    (audience = 'all' and audience_class is null
      and audience_course_id is null and audience_student_id is null)
    or (audience = 'class' and audience_class is not null)
    or (audience = 'course' and audience_course_id is not null)
    or (audience = 'student' and audience_student_id is not null)
  )
);

create table if not exists public.notification_reads (
  notification_id uuid not null references public.notifications (id) on delete cascade,
  student_id uuid not null references public.profiles (id) on delete cascade,
  read_at timestamptz not null default now(),
  primary key (notification_id, student_id)
);

-- ---------------------------------------------------------------------
-- 6. Communities (one per course, auto-joined on enrolment)
-- ---------------------------------------------------------------------

create table if not exists public.communities (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null unique references public.courses (id) on delete cascade,
  name text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.community_members (
  community_id uuid not null references public.communities (id) on delete cascade,
  student_id uuid not null references public.profiles (id) on delete cascade,
  joined_at timestamptz not null default now(),
  primary key (community_id, student_id)
);

create table if not exists public.community_messages (
  id uuid primary key default gen_random_uuid(),
  community_id uuid not null references public.communities (id) on delete cascade,
  author_id uuid references public.profiles (id) on delete set null,
  body text not null,
  pinned boolean not null default false,
  created_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- 7. Support tickets
-- ---------------------------------------------------------------------

create table if not exists public.tickets (
  id uuid primary key default gen_random_uuid(),
  reference text not null unique,
  student_id uuid not null references public.profiles (id) on delete cascade,
  subject text not null,
  category public.ticket_category not null default 'other',
  status public.ticket_status not null default 'open',
  assigned_to uuid references public.profiles (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.ticket_messages (
  id uuid primary key default gen_random_uuid(),
  ticket_id uuid not null references public.tickets (id) on delete cascade,
  author_id uuid references public.profiles (id) on delete set null,
  body text not null,
  from_support boolean not null default false,
  created_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- 8. Lecture discussion and feedback
-- ---------------------------------------------------------------------

create table if not exists public.lesson_comments (
  id uuid primary key default gen_random_uuid(),
  lesson_id uuid not null references public.lessons (id) on delete cascade,
  author_id uuid references public.profiles (id) on delete set null,
  parent_id uuid references public.lesson_comments (id) on delete cascade,
  body text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.lesson_feedback (
  id uuid primary key default gen_random_uuid(),
  lesson_id uuid not null references public.lessons (id) on delete cascade,
  student_id uuid not null references public.profiles (id) on delete cascade,
  rating smallint not null check (rating between 1 and 5),
  comment text,
  created_at timestamptz not null default now(),
  unique (lesson_id, student_id)
);

-- ---------------------------------------------------------------------
-- 9. Indexes
-- ---------------------------------------------------------------------

create index if not exists courses_published_idx on public.courses (is_published, class_level);
create index if not exists courses_slug_idx on public.courses (slug);
create index if not exists batches_course_idx on public.course_batches (course_id);
create index if not exists live_sessions_starts_idx on public.live_sessions (starts_at);
create index if not exists enrollments_student_idx on public.enrollments (student_id);
create index if not exists notifications_sent_idx on public.notifications (sent_at desc);
create index if not exists community_messages_feed_idx
  on public.community_messages (community_id, created_at desc);
create index if not exists community_members_student_idx
  on public.community_members (student_id);
create index if not exists tickets_student_idx on public.tickets (student_id, status);
create index if not exists ticket_messages_thread_idx
  on public.ticket_messages (ticket_id, created_at);
create index if not exists lesson_comments_thread_idx
  on public.lesson_comments (lesson_id, created_at);

-- ---------------------------------------------------------------------
-- 10. Functions and triggers
-- ---------------------------------------------------------------------

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists courses_updated_at on public.courses;
create trigger courses_updated_at
before update on public.courses
for each row execute function public.set_updated_at();

drop trigger if exists profiles_updated_at on public.profiles;
create trigger profiles_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

drop trigger if exists tickets_updated_at on public.tickets;
create trigger tickets_updated_at
before update on public.tickets
for each row execute function public.set_updated_at();

-- Profile on signup. Tolerates both phone OTP and OAuth (Google), which
-- arrives with an email, a name and an avatar but no phone number.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, phone, email, full_name, avatar_url, role)
  values (
    new.id,
    new.phone,
    new.email,
    coalesce(
      new.raw_user_meta_data->>'full_name',
      new.raw_user_meta_data->>'name',
      ''
    ),
    coalesce(
      new.raw_user_meta_data->>'avatar_url',
      new.raw_user_meta_data->>'picture'
    ),
    'student'
  )
  on conflict (id) do nothing;

  insert into public.student_profiles (user_id)
  values (new.id)
  on conflict (user_id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

-- Staff check used by every policy below.
create or replace function public.is_staff()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles p
    where p.id = auth.uid()
      and p.role in ('admin', 'super_admin', 'teacher')
  );
$$;

-- A community exists for every course, created with the course.
create or replace function public.create_course_community()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.communities (course_id, name)
  values (new.id, new.title)
  on conflict (course_id) do nothing;
  return new;
end;
$$;

drop trigger if exists courses_create_community on public.courses;
create trigger courses_create_community
after insert on public.courses
for each row execute function public.create_course_community();

-- Enrolling in a course joins its community, so membership follows enrolment
-- in the database rather than being managed by the apps.
create or replace function public.join_course_community()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  target_community uuid;
begin
  select c.id into target_community
  from public.communities c
  where c.course_id = new.course_id;

  if target_community is not null then
    insert into public.community_members (community_id, student_id)
    values (target_community, new.student_id)
    on conflict do nothing;
  end if;

  return new;
end;
$$;

drop trigger if exists enrollments_join_community on public.enrollments;
create trigger enrollments_join_community
after insert on public.enrollments
for each row execute function public.join_course_community();

-- ---------------------------------------------------------------------
-- 11. Row level security
-- ---------------------------------------------------------------------

alter table public.profiles enable row level security;
alter table public.student_profiles enable row level security;
alter table public.teachers enable row level security;
alter table public.courses enable row level security;
alter table public.course_batches enable row level security;
alter table public.subjects enable row level security;
alter table public.chapters enable row level security;
alter table public.lessons enable row level security;
alter table public.lesson_resources enable row level security;
alter table public.course_teachers enable row level security;
alter table public.live_sessions enable row level security;
alter table public.enrollments enable row level security;
alter table public.orders enable row level security;
alter table public.payments enable row level security;
alter table public.notifications enable row level security;
alter table public.notification_reads enable row level security;
alter table public.communities enable row level security;
alter table public.community_members enable row level security;
alter table public.community_messages enable row level security;
alter table public.tickets enable row level security;
alter table public.ticket_messages enable row level security;
alter table public.lesson_comments enable row level security;
alter table public.lesson_feedback enable row level security;

-- Policies are dropped first so this script can be re-run safely.

-- Profiles -------------------------------------------------------------
drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own"
on public.profiles for select
using (auth.uid() = id or public.is_staff());

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own"
on public.profiles for update
using (auth.uid() = id);

drop policy if exists "student_profiles_select_own" on public.student_profiles;
create policy "student_profiles_select_own"
on public.student_profiles for select
using (auth.uid() = user_id or public.is_staff());

drop policy if exists "student_profiles_update_own" on public.student_profiles;
create policy "student_profiles_update_own"
on public.student_profiles for update
using (auth.uid() = user_id);

-- Public catalog -------------------------------------------------------
drop policy if exists "courses_public_read" on public.courses;
create policy "courses_public_read"
on public.courses for select
using (is_published = true or public.is_staff());

drop policy if exists "teachers_public_read" on public.teachers;
create policy "teachers_public_read"
on public.teachers for select
using (is_active = true or public.is_staff());

drop policy if exists "course_teachers_public_read" on public.course_teachers;
create policy "course_teachers_public_read"
on public.course_teachers for select
using (true);

drop policy if exists "batches_public_read" on public.course_batches;
create policy "batches_public_read"
on public.course_batches for select
using (
  public.is_staff()
  or exists (
    select 1 from public.courses c
    where c.id = public.course_batches.course_id and c.is_published = true
  )
);

drop policy if exists "subjects_public_read" on public.subjects;
create policy "subjects_public_read"
on public.subjects for select
using (
  public.is_staff()
  or exists (
    select 1
    from public.course_batches b
    join public.courses c on c.id = b.course_id
    where b.id = public.subjects.batch_id and c.is_published = true
  )
);

drop policy if exists "chapters_public_read" on public.chapters;
create policy "chapters_public_read"
on public.chapters for select
using (
  public.is_staff()
  or exists (
    select 1
    from public.subjects s
    join public.course_batches b on b.id = s.batch_id
    join public.courses c on c.id = b.course_id
    where s.id = public.chapters.subject_id and c.is_published = true
  )
);

-- Lessons: published demos are public, the rest need an active enrolment.
drop policy if exists "lessons_demo_or_staff_read" on public.lessons;
create policy "lessons_demo_or_staff_read"
on public.lessons for select
using (
  public.is_staff()
  or (is_published = true and is_demo = true)
  or (
    is_published = true
    and exists (
      select 1
      from public.chapters ch
      join public.subjects s on s.id = ch.subject_id
      join public.course_batches b on b.id = s.batch_id
      join public.enrollments e on e.batch_id = b.id
      where ch.id = public.lessons.chapter_id
        and e.student_id = auth.uid()
        and e.status = 'active'
    )
  )
);

-- A resource is readable exactly when its lesson is: a published demo, or a
-- lesson inside a batch the student is actively enrolled in. Checking only
-- that the lesson row exists would hand every notes PDF to everyone.
drop policy if exists "lesson_resources_read" on public.lesson_resources;
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

drop policy if exists "live_sessions_enrolled_or_public_schedule" on public.live_sessions;
create policy "live_sessions_enrolled_or_public_schedule"
on public.live_sessions for select
using (
  public.is_staff()
  or exists (
    select 1
    from public.course_batches b
    join public.courses c on c.id = b.course_id
    where b.id = public.live_sessions.batch_id and c.is_published = true
  )
);

-- Enrolment and money --------------------------------------------------
drop policy if exists "enrollments_select_own" on public.enrollments;
create policy "enrollments_select_own"
on public.enrollments for select
using (auth.uid() = student_id or public.is_staff());

drop policy if exists "orders_select_own" on public.orders;
create policy "orders_select_own"
on public.orders for select
using (auth.uid() = student_id or public.is_staff());

drop policy if exists "payments_select_own" on public.payments;
create policy "payments_select_own"
on public.payments for select
using (
  public.is_staff()
  or exists (
    select 1 from public.orders o
    where o.id = public.payments.order_id and o.student_id = auth.uid()
  )
);

-- Notifications --------------------------------------------------------
drop policy if exists "notifications_read_targeted" on public.notifications;
create policy "notifications_read_targeted"
on public.notifications for select
using (
  public.is_staff()
  or audience = 'all'
  or (audience = 'student' and audience_student_id = auth.uid())
  or (
    audience = 'class'
    and exists (
      select 1 from public.student_profiles sp
      where sp.user_id = auth.uid()
        and sp.class_level = public.notifications.audience_class
    )
  )
  or (
    audience = 'course'
    and exists (
      select 1 from public.enrollments e
      where e.student_id = auth.uid()
        and e.course_id = public.notifications.audience_course_id
        and e.status = 'active'
    )
  )
);

drop policy if exists "notifications_staff_write" on public.notifications;
create policy "notifications_staff_write"
on public.notifications for all
using (public.is_staff())
with check (public.is_staff());

drop policy if exists "notification_reads_own" on public.notification_reads;
create policy "notification_reads_own"
on public.notification_reads for all
using (student_id = auth.uid())
with check (student_id = auth.uid());

-- Communities ----------------------------------------------------------
-- NOTE: the outer table is named in full inside every EXISTS below. An
-- unqualified `community_id` would bind to the subquery's own
-- community_members row, making the check trivially true and exposing
-- every community to any member of any community.
drop policy if exists "communities_member_read" on public.communities;
create policy "communities_member_read"
on public.communities for select
using (
  public.is_staff()
  or exists (
    select 1 from public.community_members m
    where m.community_id = public.communities.id and m.student_id = auth.uid()
  )
);

drop policy if exists "community_members_read" on public.community_members;
create policy "community_members_read"
on public.community_members for select
using (
  public.is_staff()
  or student_id = auth.uid()
  or exists (
    select 1 from public.community_members mine
    where mine.community_id = public.community_members.community_id
      and mine.student_id = auth.uid()
  )
);

drop policy if exists "community_messages_member_read" on public.community_messages;
create policy "community_messages_member_read"
on public.community_messages for select
using (
  public.is_staff()
  or exists (
    select 1 from public.community_members m
    where m.community_id = public.community_messages.community_id
      and m.student_id = auth.uid()
  )
);

drop policy if exists "community_messages_member_write" on public.community_messages;
create policy "community_messages_member_write"
on public.community_messages for insert
with check (
  author_id = auth.uid()
  and exists (
    select 1 from public.community_members m
    where m.community_id = public.community_messages.community_id
      and m.student_id = auth.uid()
  )
);

drop policy if exists "community_messages_author_update" on public.community_messages;
create policy "community_messages_author_update"
on public.community_messages for update
using (author_id = auth.uid() or public.is_staff());

-- Tickets --------------------------------------------------------------
drop policy if exists "tickets_own_or_staff" on public.tickets;
create policy "tickets_own_or_staff"
on public.tickets for select
using (student_id = auth.uid() or public.is_staff());

drop policy if exists "tickets_student_create" on public.tickets;
create policy "tickets_student_create"
on public.tickets for insert
with check (student_id = auth.uid());

drop policy if exists "tickets_staff_update" on public.tickets;
create policy "tickets_staff_update"
on public.tickets for update
using (public.is_staff() or student_id = auth.uid());

drop policy if exists "ticket_messages_thread_access" on public.ticket_messages;
create policy "ticket_messages_thread_access"
on public.ticket_messages for select
using (
  public.is_staff()
  or exists (
    select 1 from public.tickets t
    where t.id = public.ticket_messages.ticket_id and t.student_id = auth.uid()
  )
);

drop policy if exists "ticket_messages_write" on public.ticket_messages;
create policy "ticket_messages_write"
on public.ticket_messages for insert
with check (
  public.is_staff()
  or exists (
    select 1 from public.tickets t
    where t.id = public.ticket_messages.ticket_id and t.student_id = auth.uid()
  )
);

-- Lecture discussion and feedback --------------------------------------
drop policy if exists "lesson_comments_read" on public.lesson_comments;
create policy "lesson_comments_read"
on public.lesson_comments for select
using (true);

drop policy if exists "lesson_comments_write" on public.lesson_comments;
create policy "lesson_comments_write"
on public.lesson_comments for insert
with check (author_id = auth.uid());

drop policy if exists "lesson_comments_author_update" on public.lesson_comments;
create policy "lesson_comments_author_update"
on public.lesson_comments for update
using (author_id = auth.uid() or public.is_staff());

drop policy if exists "lesson_feedback_read" on public.lesson_feedback;
create policy "lesson_feedback_read"
on public.lesson_feedback for select
using (student_id = auth.uid() or public.is_staff());

drop policy if exists "lesson_feedback_own_write" on public.lesson_feedback;
create policy "lesson_feedback_own_write"
on public.lesson_feedback for all
using (student_id = auth.uid())
with check (student_id = auth.uid());

-- ---------------------------------------------------------------------
-- 12. Realtime
-- ---------------------------------------------------------------------
-- The app subscribes to these. Adding a table twice is an error, so each
-- one is guarded.

do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'notifications'
  ) then
    alter publication supabase_realtime add table public.notifications;
  end if;

  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public'
      and tablename = 'community_messages'
  ) then
    alter publication supabase_realtime add table public.community_messages;
  end if;

  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public'
      and tablename = 'ticket_messages'
  ) then
    alter publication supabase_realtime add table public.ticket_messages;
  end if;
exception
  when undefined_object then
    raise notice 'supabase_realtime publication not found — skipping realtime setup.';
end
$$;

-- ---------------------------------------------------------------------
-- 13. Backfill
-- ---------------------------------------------------------------------
-- For projects that already had courses or enrolments before the community
-- tables existed.

insert into public.communities (course_id, name)
select c.id, c.title from public.courses c
on conflict (course_id) do nothing;

insert into public.community_members (community_id, student_id)
select cm.id, e.student_id
from public.enrollments e
join public.communities cm on cm.course_id = e.course_id
on conflict do nothing;

-- =====================================================================
-- Done. Next steps:
--   1. supabase/seed.sql            — sample courses and teachers
--   2. Auth → Providers → Google    — enable and paste your OAuth client
--   3. Make yourself an admin:
--        update public.profiles set role = 'super_admin'
--        where email = 'you@example.com';
-- =====================================================================


-- =====================================================================
-- SLICE 4 — popups, push, doubt queue, storage, staff write policies
-- =====================================================================
-- Consolidated from migrations/20261006000100_popups_push_and_admin_writes.sql
--
-- This section is REQUIRED. Everything above enables row-level security but
-- defines SELECT policies only, and under RLS a missing policy denies — so
-- without the policies below every admin write fails. It also closes a
-- privilege escalation where a student could set their own role to
-- super_admin.
-- =====================================================================

do $$ begin
  create type public.popup_placement as enum ('app_launch', 'home', 'course');
exception when duplicate_object then null;
end $$;
do $$ begin
  create type public.push_status as enum ('queued', 'sent', 'failed');
exception when duplicate_object then null;
end $$;

-- =============================================================== popups

-- Interstitial cards the app shows on launch / home / a course screen.
-- Audience targeting mirrors `notifications` so the admin UI can share code.
create table if not exists public.popups (
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
create table if not exists public.popup_views (
  popup_id uuid not null references public.popups (id) on delete cascade,
  student_id uuid not null references public.profiles (id) on delete cascade,
  view_count integer not null default 1,
  dismissed_at timestamptz,
  clicked_at timestamptz,
  last_seen_at timestamptz not null default now(),
  primary key (popup_id, student_id)
);

create index if not exists popups_live_idx on public.popups (is_active, starts_at, ends_at);
create index if not exists popups_priority_idx on public.popups (priority desc, created_at desc);

drop trigger if exists popups_updated_at on public.popups;
create trigger popups_updated_at
before update on public.popups
for each row execute function public.set_updated_at();

-- ========================================================= push delivery

-- One row per installed app instance. `user_id` is null between app launch
-- and sign-in, so a token is claimed on login rather than created there.
create table if not exists public.device_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles (id) on delete cascade,
  token text not null unique,
  platform text not null check (platform in ('android', 'ios', 'web')),
  app_version text,
  is_active boolean not null default true,
  last_seen_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create index if not exists device_tokens_user_idx on public.device_tokens (user_id) where is_active;

-- Delivery log: the admin console writes a notification, the Edge Function
-- fans it out to tokens and writes the outcome back here.
create table if not exists public.push_deliveries (
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

create index if not exists push_deliveries_notification_idx on public.push_deliveries (notification_id);

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

create index if not exists lesson_comments_doubt_queue_idx
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
drop policy if exists "popups_read_targeted" on public.popups;
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

drop policy if exists "popups_staff_write" on public.popups;
create policy "popups_staff_write"
on public.popups for all
using (public.is_staff())
with check (public.is_staff());

drop policy if exists "popup_views_own" on public.popup_views;
create policy "popup_views_own"
on public.popup_views for all
using (student_id = auth.uid() or public.is_staff())
with check (student_id = auth.uid());

-- A device token belongs to whoever claimed it. Unclaimed rows (user_id null)
-- are insert-only from the client and never readable back.
drop policy if exists "device_tokens_own_read" on public.device_tokens;
create policy "device_tokens_own_read"
on public.device_tokens for select
using (user_id = auth.uid() or public.is_staff());

drop policy if exists "device_tokens_insert" on public.device_tokens;
create policy "device_tokens_insert"
on public.device_tokens for insert
with check (user_id is null or user_id = auth.uid());

drop policy if exists "device_tokens_own_update" on public.device_tokens;
create policy "device_tokens_own_update"
on public.device_tokens for update
using (user_id = auth.uid() or public.is_staff())
with check (user_id = auth.uid() or public.is_staff());

drop policy if exists "device_tokens_own_delete" on public.device_tokens;
create policy "device_tokens_own_delete"
on public.device_tokens for delete
using (user_id = auth.uid() or public.is_staff());

drop policy if exists "push_deliveries_staff_only" on public.push_deliveries;
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

drop policy if exists "courses_admin_write" on public.courses;
create policy "courses_admin_write"
on public.courses for all
using (public.is_admin())
with check (public.is_admin());

drop policy if exists "teachers_admin_write" on public.teachers;
create policy "teachers_admin_write"
on public.teachers for all
using (public.is_admin())
with check (public.is_admin());

drop policy if exists "course_teachers_admin_write" on public.course_teachers;
create policy "course_teachers_admin_write"
on public.course_teachers for all
using (public.is_admin())
with check (public.is_admin());

-- Curriculum structure and content: any staff member, teachers included.
drop policy if exists "batches_staff_write" on public.course_batches;
create policy "batches_staff_write"
on public.course_batches for all
using (public.is_staff())
with check (public.is_staff());

drop policy if exists "subjects_staff_write" on public.subjects;
create policy "subjects_staff_write"
on public.subjects for all
using (public.is_staff())
with check (public.is_staff());

drop policy if exists "chapters_staff_write" on public.chapters;
create policy "chapters_staff_write"
on public.chapters for all
using (public.is_staff())
with check (public.is_staff());

drop policy if exists "lessons_staff_write" on public.lessons;
create policy "lessons_staff_write"
on public.lessons for all
using (public.is_staff())
with check (public.is_staff());

drop policy if exists "lesson_resources_staff_write" on public.lesson_resources;
create policy "lesson_resources_staff_write"
on public.lesson_resources for all
using (public.is_staff())
with check (public.is_staff());

drop policy if exists "live_sessions_staff_write" on public.live_sessions;
create policy "live_sessions_staff_write"
on public.live_sessions for all
using (public.is_staff())
with check (public.is_staff());

-- Manual enrolment (offline payment, comped access) from the students page.
drop policy if exists "enrollments_admin_write" on public.enrollments;
create policy "enrollments_admin_write"
on public.enrollments for all
using (public.is_admin())
with check (public.is_admin());

-- Staff edit student records; `profiles_update_own` already covers self-edit.
drop policy if exists "profiles_admin_update" on public.profiles;
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

drop trigger if exists profiles_protect_role on public.profiles;
create trigger profiles_protect_role
before update on public.profiles
for each row execute function public.protect_profile_role();

drop policy if exists "student_profiles_staff_write" on public.student_profiles;
create policy "student_profiles_staff_write"
on public.student_profiles for all
using (public.is_staff())
with check (public.is_staff());

-- Communities: staff create them and post pinned announcements.
drop policy if exists "communities_staff_write" on public.communities;
create policy "communities_staff_write"
on public.communities for all
using (public.is_staff())
with check (public.is_staff());

drop policy if exists "community_members_staff_write" on public.community_members;
create policy "community_members_staff_write"
on public.community_members for all
using (public.is_staff())
with check (public.is_staff());

-- Slice 3 let a member insert only as themselves, which blocks staff
-- announcements. Widen insert and allow staff to delete a message.
drop policy if exists "community_messages_member_write" on public.community_messages;
drop policy if exists "community_messages_write" on public.community_messages;
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

drop policy if exists "community_messages_staff_delete" on public.community_messages;
create policy "community_messages_staff_delete"
on public.community_messages for delete
using (public.is_staff());

-- Staff close or reassign a ticket; students can no longer flip their own
-- status (slice 3's `tickets_staff_update` allowed it).
drop policy if exists "tickets_staff_update" on public.tickets;
drop policy if exists "tickets_staff_update" on public.tickets;
create policy "tickets_staff_update"
on public.tickets for update
using (public.is_staff())
with check (public.is_staff());

drop policy if exists "lesson_comments_staff_delete" on public.lesson_comments;
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
drop policy if exists "lesson_notes_staff_all" on storage.objects;
create policy "lesson_notes_staff_all"
on storage.objects for all
to authenticated
using (bucket_id = 'lesson-notes' and public.is_staff())
with check (bucket_id = 'lesson-notes' and public.is_staff());

drop policy if exists "lesson_videos_staff_all" on storage.objects;
create policy "lesson_videos_staff_all"
on storage.objects for all
to authenticated
using (bucket_id = 'lesson-videos' and public.is_staff())
with check (bucket_id = 'lesson-videos' and public.is_staff());

-- Public buckets: anyone reads, staff writes.
drop policy if exists "public_images_read" on storage.objects;
create policy "public_images_read"
on storage.objects for select
using (bucket_id in ('popup-images', 'course-thumbnails'));

drop policy if exists "public_images_staff_write" on storage.objects;
create policy "public_images_staff_write"
on storage.objects for all
to authenticated
using (bucket_id in ('popup-images', 'course-thumbnails') and public.is_staff())
with check (bucket_id in ('popup-images', 'course-thumbnails') and public.is_staff());

-- ============================================================== realtime

do $$ begin
  alter publication supabase_realtime add table public.popups;
exception when duplicate_object then null;
end $$;
