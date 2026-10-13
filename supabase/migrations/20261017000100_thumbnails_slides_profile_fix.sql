-- Migration 12: course thumbnails, launch slides for the app's Home slider,
-- and a fix for saving class & stream from the app.

-- ------------------------------------------------------- student profile
--
-- The app saves class/stream/medium with an upsert. Postgres checks INSERT
-- policies for an upsert even when the row already exists, and students only
-- had an UPDATE policy, so every save was rejected. Let a student create
-- their own row (and only their own).
drop policy if exists "student_profiles_insert_own" on public.student_profiles;
create policy "student_profiles_insert_own"
on public.student_profiles for insert
with check (auth.uid() = user_id);

-- The update policy had no WITH CHECK; make it explicit that the row stays
-- the student's own.
drop policy if exists "student_profiles_update_own" on public.student_profiles;
create policy "student_profiles_update_own"
on public.student_profiles for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

-- ------------------------------------------------------------ thumbnails
--
-- Images uploaded to the public course-thumbnails bucket under launch/.
-- Only fills courses that have no thumbnail yet, so console uploads win.
update public.courses c
set thumbnail_url =
  'https://wjohjdeoitompidjvxgb.supabase.co/storage/v1/object/public/course-thumbnails/launch/' || t.file
from (values
  ('free-demo-course', 'demo-yt.jpg'),
  ('class-12-science-crash-course-2027', 'feature-live-class.jpg'),
  ('class-12-physics-crash-course', 'feature-live-class.jpg'),
  ('class-12-commerce-crash-course', 'feature-notes.jpg'),
  ('class-12-arts-crash-course', 'feature-notes.jpg'),
  ('class-11-science-crash-course', 'hero-students.jpg'),
  ('class-11-commerce-crash-course', 'hero-students.jpg')
) as t(slug, file)
where c.slug = t.slug and c.thumbnail_url is null;

-- --------------------------------------------------------------- slides
insert into public.course_banners (
  id, title, subtitle, image_path, course_id, cta_label, hue, sort_order, is_active
) values
  ('b0000000-0000-4000-8000-000000000001',
   'Start learning free',
   'Free Demo Course — lectures and notes, no payment',
   'launch/demo-yt.jpg', 'c0000000-0000-4000-8000-0000000000f0',
   'Start now', 214, 1, true),
  ('b0000000-0000-4000-8000-000000000002',
   'Board 2027 crash courses',
   'Class 12 Science — 50% off this week',
   'launch/feature-live-class.jpg', 'c0000000-0000-4000-8000-000000000001',
   'View course', 230, 2, true)
on conflict do nothing;
