-- Migration 11: a free demo course every account gets, for trying the app.
--
-- "Free Demo Course" costs ₹0 and every lesson in it is a demo lesson, so the
-- player and notes open for anyone signed in. Free courses (published,
-- price 0) are also enrolled automatically — existing accounts now, and every
-- new account at sign-up — so the course shows under My courses straight away.
--
-- The lectures are the Gen-Z IITian videos and the Drive notes already used
-- as demos in migration 9. Fixed ids keep this safe to re-run.

insert into public.courses (
  id, slug, title, description, class_level, language, thumbnail_hue,
  price_inr, original_price_inr, rating, lessons_count, highlights, subjects,
  is_published
) values (
  'c0000000-0000-4000-8000-0000000000f0', 'free-demo-course', 'Free Demo Course',
  'Try the full classroom for free: recorded lectures in the secure player and chapter notes in the in-app viewer.',
  12, 'Hindi + English', 230, 0, null, 4.9, 6,
  '{"Free for every student","Recorded lectures","Chapter notes PDF","Works on web and app"}',
  '{Mathematics}', true
)
on conflict do nothing;

insert into public.course_teachers (course_id, teacher_id, is_primary) values
  ('c0000000-0000-4000-8000-0000000000f0', '7e000000-0000-4000-8000-000000000001', true)
on conflict do nothing;

insert into public.course_batches (id, course_id, name, starts_on, ends_on) values
  ('ba000000-0000-4000-8000-0000000000f0', 'c0000000-0000-4000-8000-0000000000f0',
   'Open Batch', '2026-10-01', '2027-03-31')
on conflict do nothing;

insert into public.subjects (id, batch_id, name, sort_order) values
  ('ba000000-0000-4000-8000-0000000000f1', 'ba000000-0000-4000-8000-0000000000f0', 'Mathematics', 1)
on conflict do nothing;

insert into public.chapters (id, subject_id, title, sort_order) values
  ('c4000000-0000-4000-8000-0000000000f1', 'ba000000-0000-4000-8000-0000000000f1', 'Sets, Relations and Functions', 1),
  ('c4000000-0000-4000-8000-0000000000f2', 'ba000000-0000-4000-8000-0000000000f1', 'Statistics', 2),
  ('c4000000-0000-4000-8000-0000000000f3', 'ba000000-0000-4000-8000-0000000000f1', 'Vectors and Matrices', 3),
  ('c4000000-0000-4000-8000-0000000000f4', 'ba000000-0000-4000-8000-0000000000f1', 'Linear Equations and Determinants', 4)
on conflict do nothing;

insert into public.lessons (
  id, chapter_id, title, lesson_type, sort_order, duration_seconds,
  video_provider, video_ref, is_demo, is_published
) values
  ('1e000000-0000-4000-8000-0000000000f1', 'c4000000-0000-4000-8000-0000000000f1',
   'Sets, Relations & Functions — Detailed Theory', 'VIDEO', 1, 2375, 'youtube', 'TuK415Wz0Q0', true, true),
  ('1e000000-0000-4000-8000-0000000000f2', 'c4000000-0000-4000-8000-0000000000f1',
   'Class notes · Logarithmic functions', 'PDF', 2, null, null, null, true, true),
  ('1e000000-0000-4000-8000-0000000000f3', 'c4000000-0000-4000-8000-0000000000f2',
   'Statistics — Detailed Hindi Lecture', 'VIDEO', 1, 2477, 'youtube', '2Pf9oKazhiQ', true, true),
  ('1e000000-0000-4000-8000-0000000000f4', 'c4000000-0000-4000-8000-0000000000f2',
   'Class notes · Maths 1 Week 5', 'PDF', 2, null, null, null, true, true),
  ('1e000000-0000-4000-8000-0000000000f5', 'c4000000-0000-4000-8000-0000000000f3',
   'Vectors & Matrices', 'VIDEO', 1, 4325, 'youtube', 'W76RnM-86DE', true, true),
  ('1e000000-0000-4000-8000-0000000000f6', 'c4000000-0000-4000-8000-0000000000f4',
   'Linear Equations & Determinants', 'VIDEO', 1, 3109, 'youtube', 'Nd48fIotQyo', true, true)
on conflict do nothing;

insert into public.lesson_resources (
  id, lesson_id, title, resource_type, source, drive_file_id, is_downloadable
) values
  ('2e000000-0000-4000-8000-0000000000f1', '1e000000-0000-4000-8000-0000000000f2',
   'Logarithmic Functions — Exercises', 'PDF', 'gdrive', '13vVIe_8WNGfxhE67JWJJEeaNpwvjCaZ2', false),
  ('2e000000-0000-4000-8000-0000000000f2', '1e000000-0000-4000-8000-0000000000f4',
   'Maths 1 · Week 5 Notes', 'PDF', 'gdrive', '1Q4zw5HKVBD2qqYYy-BEt17mvIhguGiik', false)
on conflict do nothing;

-- ------------------------------------------------- automatic enrolment

create or replace function public.enroll_in_free_courses()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.enrollments (student_id, course_id, batch_id, status)
  select new.id, c.id,
         (select b.id from public.course_batches b
          where b.course_id = c.id and b.is_active
          order by b.created_at desc limit 1),
         'active'
  from public.courses c
  where c.is_published and c.price_inr = 0
  on conflict (student_id, course_id) do nothing;
  return new;
end;
$$;

drop trigger if exists profiles_enroll_free_courses on public.profiles;
create trigger profiles_enroll_free_courses
after insert on public.profiles
for each row execute function public.enroll_in_free_courses();

-- Everyone who already has an account.
insert into public.enrollments (student_id, course_id, batch_id, status)
select p.id, 'c0000000-0000-4000-8000-0000000000f0',
       'ba000000-0000-4000-8000-0000000000f0', 'active'
from public.profiles p
on conflict (student_id, course_id) do nothing;
