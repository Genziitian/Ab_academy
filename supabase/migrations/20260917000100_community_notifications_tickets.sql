-- Akhand Bharat Academy — notifications, communities, tickets and lecture extras
-- Slice 3: the tables behind the admin console, the per-course community,
-- the support ticket system, and the discussion/feedback under each lecture.
--
-- Written to be applied against the schema created by
-- 20260315000100_init_schema.sql. Nothing here is applied yet — there is no
-- Supabase project connected.

-- ---------------------------------------------------------------- enums

create type public.notification_audience as enum ('all', 'class', 'course', 'student');
create type public.ticket_status as enum ('open', 'in_progress', 'resolved', 'closed');
create type public.ticket_category as enum ('payment', 'content', 'technical', 'account', 'other');

-- -------------------------------------------------------- notifications

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  body text not null,
  audience public.notification_audience not null default 'all',
  -- Exactly one of these is set, matching `audience`; all null means everyone.
  audience_class smallint check (audience_class between 9 and 12),
  audience_course_id uuid references public.courses (id) on delete cascade,
  audience_student_id uuid references public.profiles (id) on delete cascade,
  created_by uuid references public.profiles (id) on delete set null,
  sent_at timestamptz not null default now(),
  constraint notifications_audience_target check (
    (audience = 'all' and audience_class is null and audience_course_id is null and audience_student_id is null)
    or (audience = 'class' and audience_class is not null)
    or (audience = 'course' and audience_course_id is not null)
    or (audience = 'student' and audience_student_id is not null)
  )
);

create table public.notification_reads (
  notification_id uuid not null references public.notifications (id) on delete cascade,
  student_id uuid not null references public.profiles (id) on delete cascade,
  read_at timestamptz not null default now(),
  primary key (notification_id, student_id)
);

create index notifications_sent_idx on public.notifications (sent_at desc);

-- ------------------------------------------------------------ communities

create table public.communities (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null unique references public.courses (id) on delete cascade,
  name text not null,
  created_at timestamptz not null default now()
);

create table public.community_members (
  community_id uuid not null references public.communities (id) on delete cascade,
  student_id uuid not null references public.profiles (id) on delete cascade,
  joined_at timestamptz not null default now(),
  primary key (community_id, student_id)
);

create table public.community_messages (
  id uuid primary key default gen_random_uuid(),
  community_id uuid not null references public.communities (id) on delete cascade,
  author_id uuid references public.profiles (id) on delete set null,
  body text not null,
  pinned boolean not null default false,
  created_at timestamptz not null default now()
);

create index community_messages_feed_idx on public.community_messages (community_id, created_at desc);
create index community_members_student_idx on public.community_members (student_id);

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

create trigger courses_create_community
after insert on public.courses
for each row execute function public.create_course_community();

-- Enrolling in a course joins its community. This is why the app never has to
-- manage membership: it follows enrolment.
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

create trigger enrollments_join_community
after insert on public.enrollments
for each row execute function public.join_course_community();

-- Backfill for rows that already exist.
insert into public.communities (course_id, name)
select c.id, c.title from public.courses c
on conflict (course_id) do nothing;

insert into public.community_members (community_id, student_id)
select cm.id, e.student_id
from public.enrollments e
join public.communities cm on cm.course_id = e.course_id
on conflict do nothing;

-- ---------------------------------------------------------------- tickets

create table public.tickets (
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

create table public.ticket_messages (
  id uuid primary key default gen_random_uuid(),
  ticket_id uuid not null references public.tickets (id) on delete cascade,
  author_id uuid references public.profiles (id) on delete set null,
  body text not null,
  from_support boolean not null default false,
  created_at timestamptz not null default now()
);

create index tickets_student_idx on public.tickets (student_id, status);
create index ticket_messages_thread_idx on public.ticket_messages (ticket_id, created_at);

create trigger tickets_updated_at
before update on public.tickets
for each row execute function public.set_updated_at();

-- ------------------------------------------------------- lecture extras

create table public.lesson_comments (
  id uuid primary key default gen_random_uuid(),
  lesson_id uuid not null references public.lessons (id) on delete cascade,
  author_id uuid references public.profiles (id) on delete set null,
  parent_id uuid references public.lesson_comments (id) on delete cascade,
  body text not null,
  created_at timestamptz not null default now()
);

create table public.lesson_feedback (
  id uuid primary key default gen_random_uuid(),
  lesson_id uuid not null references public.lessons (id) on delete cascade,
  student_id uuid not null references public.profiles (id) on delete cascade,
  rating smallint not null check (rating between 1 and 5),
  comment text,
  created_at timestamptz not null default now(),
  unique (lesson_id, student_id)
);

create index lesson_comments_thread_idx on public.lesson_comments (lesson_id, created_at);

-- ------------------------------------------------------------------ RLS

alter table public.notifications enable row level security;
alter table public.notification_reads enable row level security;
alter table public.communities enable row level security;
alter table public.community_members enable row level security;
alter table public.community_messages enable row level security;
alter table public.tickets enable row level security;
alter table public.ticket_messages enable row level security;
alter table public.lesson_comments enable row level security;
alter table public.lesson_feedback enable row level security;

-- Students read notifications aimed at them; staff manage all of them.
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

create policy "notifications_staff_write"
on public.notifications for all
using (public.is_staff())
with check (public.is_staff());

create policy "notification_reads_own"
on public.notification_reads for all
using (student_id = auth.uid())
with check (student_id = auth.uid());

-- Communities are visible to their members (and staff).
create policy "communities_member_read"
on public.communities for select
using (
  public.is_staff()
  or exists (
    select 1 from public.community_members m
    where m.community_id = public.communities.id and m.student_id = auth.uid()
  )
);

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

create policy "community_messages_author_update"
on public.community_messages for update
using (author_id = auth.uid() or public.is_staff());

-- Tickets: a student sees only their own; staff see everything.
create policy "tickets_own_or_staff"
on public.tickets for select
using (student_id = auth.uid() or public.is_staff());

create policy "tickets_student_create"
on public.tickets for insert
with check (student_id = auth.uid());

create policy "tickets_staff_update"
on public.tickets for update
using (public.is_staff() or student_id = auth.uid());

create policy "ticket_messages_thread_access"
on public.ticket_messages for select
using (
  public.is_staff()
  or exists (
    select 1 from public.tickets t
    where t.id = public.ticket_messages.ticket_id and t.student_id = auth.uid()
  )
);

create policy "ticket_messages_write"
on public.ticket_messages for insert
with check (
  public.is_staff()
  or exists (
    select 1 from public.tickets t
    where t.id = public.ticket_messages.ticket_id and t.student_id = auth.uid()
  )
);

-- Lecture discussion and feedback follow lesson access.
create policy "lesson_comments_read"
on public.lesson_comments for select
using (true);

create policy "lesson_comments_write"
on public.lesson_comments for insert
with check (author_id = auth.uid());

create policy "lesson_comments_author_update"
on public.lesson_comments for update
using (author_id = auth.uid() or public.is_staff());

create policy "lesson_feedback_read"
on public.lesson_feedback for select
using (student_id = auth.uid() or public.is_staff());

create policy "lesson_feedback_own_write"
on public.lesson_feedback for all
using (student_id = auth.uid())
with check (student_id = auth.uid());

-- ------------------------------------------------------------- realtime

-- The app subscribes to these for live updates.
alter publication supabase_realtime add table public.notifications;
alter publication supabase_realtime add table public.community_messages;
alter publication supabase_realtime add table public.ticket_messages;

-- ------------------------------------------------- OAuth-friendly signup

-- The original trigger assumed phone signup. Google sign-in arrives with an
-- email, a name and an avatar but no phone, so read all of them defensively.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, phone, full_name, avatar_url, role)
  values (
    new.id,
    new.phone,
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

-- `profiles.phone` is unique and nullable, which suits OAuth users with no
-- phone number; add the email column the provider gives us.
alter table public.profiles add column if not exists email text;
create unique index if not exists profiles_email_idx on public.profiles (email) where email is not null;
