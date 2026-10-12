-- Migration 5: course banners for the app's slider, and what checkout needs.
--
-- course_banners  — the slides at the top of Home and the Courses store,
--                   managed from /admin/banners.
-- banner-images   — public bucket for slide artwork.
-- orders          — payment ids that Razorpay returns, so a verified payment
--                   can be matched back to its order exactly once.

-- ========================================================= course banners

create table public.course_banners (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  subtitle text,
  -- Optional uploaded artwork; without it the slide is a gradient in the
  -- linked course's hue (or `hue` below).
  image_path text,
  -- Where a tap goes. A course opens its course page; neither means the slide
  -- is informational only.
  course_id uuid references public.courses (id) on delete set null,
  cta_label text not null default 'View course',
  hue integer not null default 214 check (hue between 0 and 360),
  sort_order integer not null default 0,
  is_active boolean not null default true,
  starts_at timestamptz not null default now(),
  ends_at timestamptz,
  created_at timestamptz not null default now(),
  constraint course_banners_window check (ends_at is null or ends_at > starts_at)
);

create index course_banners_live_idx
on public.course_banners (is_active, sort_order);

alter table public.course_banners enable row level security;

-- Anyone, signed in or not, sees the slides that are live right now; staff
-- also see drafts and scheduled ones.
create policy "course_banners_read_live"
on public.course_banners for select
using (
  public.is_staff()
  or (
    is_active = true
    and starts_at <= now()
    and (ends_at is null or ends_at > now())
  )
);

create policy "course_banners_staff_write"
on public.course_banners for all
using (public.is_staff())
with check (public.is_staff());

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('banner-images', 'banner-images', true, 5242880, array['image/png', 'image/jpeg', 'image/webp'])
on conflict (id) do nothing;

create policy "banner_images_public_read"
on storage.objects for select
using (bucket_id = 'banner-images');

create policy "banner_images_staff_write"
on storage.objects for all
using (bucket_id = 'banner-images' and public.is_staff())
with check (bucket_id = 'banner-images' and public.is_staff());

-- ================================================================ checkout

-- Orders and payments are written only by the `checkout` Edge Function with
-- the service role; students keep read-only access to their own rows
-- (orders_select_own / payments_select_own from migration 1).

alter table public.orders
  add column if not exists razorpay_payment_id text unique,
  add column if not exists paid_at timestamptz;

create index if not exists orders_student_idx on public.orders (student_id, created_at desc);
