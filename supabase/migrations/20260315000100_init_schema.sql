-- Akhand Bharat Academy — core catalog + identity foundation
-- Slice 2: public course catalog tables with RLS

create extension if not exists "pgcrypto";

-- Roles on profiles (auth.users is managed by Supabase Auth)
create type public.user_role as enum ('student', 'teacher', 'admin', 'super_admin');
create type public.lesson_type as enum ('LIVE', 'VIDEO', 'PDF', 'TEST', 'ASSIGNMENT');
create type public.live_provider as enum ('youtube', 'jitsi');
create type public.live_status as enum (
  'SCHEDULED',
  'LIVE',
  'ENDED',
  'RECORDING_PROCESSING',
  'RECORDING_AVAILABLE'
);
create type public.enrollment_status as enum ('active', 'expired', 'cancelled', 'refunded');
create type public.order_status as enum ('created', 'pending', 'paid', 'failed', 'refunded');

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  phone text unique,
  full_name text,
  avatar_url text,
  role public.user_role not null default 'student',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.student_profiles (
  user_id uuid primary key references public.profiles (id) on delete cascade,
  class_level smallint check (class_level between 9 and 12),
  board text default 'Bihar Board',
  medium text check (medium in ('Hindi', 'English')),
  stream text,
  school text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.teachers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid unique references public.profiles (id) on delete set null,
  display_name text not null,
  bio text,
  avatar_url text,
  subjects text[] default '{}',
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.courses (
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

create table public.course_batches (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references public.courses (id) on delete cascade,
  name text not null,
  starts_on date,
  ends_on date,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.subjects (
  id uuid primary key default gen_random_uuid(),
  batch_id uuid not null references public.course_batches (id) on delete cascade,
  name text not null,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

create table public.chapters (
  id uuid primary key default gen_random_uuid(),
  subject_id uuid not null references public.subjects (id) on delete cascade,
  title text not null,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

create table public.lessons (
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

create table public.lesson_resources (
  id uuid primary key default gen_random_uuid(),
  lesson_id uuid not null references public.lessons (id) on delete cascade,
  title text not null,
  resource_type text not null default 'PDF',
  storage_path text not null,
  created_at timestamptz not null default now()
);

create table public.course_teachers (
  course_id uuid not null references public.courses (id) on delete cascade,
  teacher_id uuid not null references public.teachers (id) on delete cascade,
  is_primary boolean not null default false,
  primary key (course_id, teacher_id)
);

create table public.live_sessions (
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

create table public.enrollments (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.profiles (id) on delete cascade,
  course_id uuid not null references public.courses (id) on delete cascade,
  batch_id uuid references public.course_batches (id) on delete set null,
  status public.enrollment_status not null default 'active',
  purchased_at timestamptz not null default now(),
  expires_at timestamptz,
  unique (student_id, course_id)
);

create table public.orders (
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

create table public.payments (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  razorpay_payment_id text unique,
  amount_inr integer not null,
  status text not null,
  raw_payload jsonb,
  created_at timestamptz not null default now()
);

create index courses_published_idx on public.courses (is_published, class_level);
create index courses_slug_idx on public.courses (slug);
create index batches_course_idx on public.course_batches (course_id);
create index live_sessions_starts_idx on public.live_sessions (starts_at);
create index enrollments_student_idx on public.enrollments (student_id);

-- updated_at helper
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger courses_updated_at
before update on public.courses
for each row execute function public.set_updated_at();

create trigger profiles_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

-- Auto-create profile on signup
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, phone, full_name, role)
  values (
    new.id,
    new.phone,
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    'student'
  );
  insert into public.student_profiles (user_id)
  values (new.id);
  return new;
end;
$$;

create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

-- RLS
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

-- Profiles: owner read/update
create policy "profiles_select_own"
on public.profiles for select
using (auth.uid() = id or public.is_staff());

create policy "profiles_update_own"
on public.profiles for update
using (auth.uid() = id);

create policy "student_profiles_select_own"
on public.student_profiles for select
using (auth.uid() = user_id or public.is_staff());

create policy "student_profiles_update_own"
on public.student_profiles for update
using (auth.uid() = user_id);

-- Public catalog
create policy "courses_public_read"
on public.courses for select
using (is_published = true or public.is_staff());

create policy "teachers_public_read"
on public.teachers for select
using (is_active = true or public.is_staff());

create policy "course_teachers_public_read"
on public.course_teachers for select
using (true);

create policy "batches_public_read"
on public.course_batches for select
using (
  public.is_staff()
  or exists (
    select 1 from public.courses c
    where c.id = course_id and c.is_published = true
  )
);

create policy "subjects_public_read"
on public.subjects for select
using (
  public.is_staff()
  or exists (
    select 1
    from public.course_batches b
    join public.courses c on c.id = b.course_id
    where b.id = batch_id and c.is_published = true
  )
);

create policy "chapters_public_read"
on public.chapters for select
using (
  public.is_staff()
  or exists (
    select 1
    from public.subjects s
    join public.course_batches b on b.id = s.batch_id
    join public.courses c on c.id = b.course_id
    where s.id = subject_id and c.is_published = true
  )
);

-- Lessons: published demos public; other lessons require enrollment (later tightened)
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
      where ch.id = chapter_id
        and e.student_id = auth.uid()
        and e.status = 'active'
    )
  )
);

create policy "enrollments_select_own"
on public.enrollments for select
using (auth.uid() = student_id or public.is_staff());

create policy "orders_select_own"
on public.orders for select
using (auth.uid() = student_id or public.is_staff());

create policy "payments_select_own"
on public.payments for select
using (
  public.is_staff()
  or exists (
    select 1 from public.orders o
    where o.id = order_id and o.student_id = auth.uid()
  )
);

create policy "live_sessions_enrolled_or_public_schedule"
on public.live_sessions for select
using (
  public.is_staff()
  or exists (
    select 1
    from public.course_batches b
    join public.courses c on c.id = b.course_id
    where b.id = batch_id and c.is_published = true
  )
);
