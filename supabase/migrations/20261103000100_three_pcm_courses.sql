-- The catalog becomes three Class 12 courses — Physics, Chemistry and Maths —
-- at ₹249 each, all taught by Ajit Sir. Every other paid course is
-- unpublished, not deleted, so existing enrolments, orders and content stay
-- intact and a course can be brought back from Admin → Courses.
--
-- The free demo course stays published as the free sample.
-- Ratings start at 0; the website and app hide a rating until it is real.

-- ------------------------------------------------------------ teacher

insert into public.teachers (id, display_name, bio, subjects)
values (
  '7e000000-0000-4000-8000-000000000010',
  'Ajit Sir',
  'One teacher for all three subjects, so concepts connect across Physics, Chemistry and Maths. Ajit Sir records every class and takes every live doubt session himself.',
  '{Physics,Chemistry,Mathematics}'
)
on conflict (id) do update
set display_name = excluded.display_name,
    bio = excluded.bio,
    subjects = excluded.subjects;

-- ------------------------------------------------------------ courses

-- Physics already exists (it carries the demo curriculum); update it in place.
update public.courses
set title = 'Class 12 Physics Crash Course',
    description = 'Every Class 12 Physics chapter as a recorded class, with live doubt sessions, chapter notes and board-pattern questions.',
    language = 'Hindi + English',
    price_inr = 249,
    original_price_inr = null,
    rating = 0,
    lessons_count = 14,
    thumbnail_hue = 20,
    highlights = '{"Recorded class for every chapter","Live doubt sessions with Ajit Sir","Chapter notes PDF","Board-pattern questions"}',
    subjects = '{Physics}',
    is_published = true
where id = 'c0000000-0000-4000-8000-000000000002';

insert into public.courses (
  id, slug, title, description, class_level, language, thumbnail_hue,
  price_inr, original_price_inr, rating, lessons_count, highlights, subjects,
  is_published
) values
  ('c0000000-0000-4000-8000-000000000007', 'class-12-chemistry-crash-course',
   'Class 12 Chemistry Crash Course',
   'Every Class 12 Chemistry chapter as a recorded class, with live doubt sessions, chapter notes and board-pattern questions.',
   12, 'Hindi + English', 150, 249, null, 0, 10,
   '{"Recorded class for every chapter","Live doubt sessions with Ajit Sir","Chapter notes PDF","Board-pattern questions"}',
   '{Chemistry}', true),
  ('c0000000-0000-4000-8000-000000000008', 'class-12-maths-crash-course',
   'Class 12 Maths Crash Course',
   'Every Class 12 Maths chapter as a recorded class, with live doubt sessions, chapter notes and board-pattern questions.',
   12, 'Hindi + English', 270, 249, null, 0, 13,
   '{"Recorded class for every chapter","Live doubt sessions with Ajit Sir","Chapter notes PDF","Board-pattern questions"}',
   '{Mathematics}', true)
on conflict (id) do update
set title = excluded.title,
    description = excluded.description,
    language = excluded.language,
    thumbnail_hue = excluded.thumbnail_hue,
    price_inr = excluded.price_inr,
    original_price_inr = excluded.original_price_inr,
    lessons_count = excluded.lessons_count,
    highlights = excluded.highlights,
    subjects = excluded.subjects,
    is_published = true;

-- Ajit Sir is the one (primary) teacher on all three.
delete from public.course_teachers
where course_id in (
  'c0000000-0000-4000-8000-000000000002',
  'c0000000-0000-4000-8000-000000000007',
  'c0000000-0000-4000-8000-000000000008'
);

insert into public.course_teachers (course_id, teacher_id, is_primary) values
  ('c0000000-0000-4000-8000-000000000002', '7e000000-0000-4000-8000-000000000010', true),
  ('c0000000-0000-4000-8000-000000000007', '7e000000-0000-4000-8000-000000000010', true),
  ('c0000000-0000-4000-8000-000000000008', '7e000000-0000-4000-8000-000000000010', true);

-- ------------------------------------------------------------ the rest

-- Unpublish every other paid course (Science, Commerce, Arts, Class 11 …).
update public.courses
set is_published = false
where price_inr > 0
  and id not in (
    'c0000000-0000-4000-8000-000000000002',
    'c0000000-0000-4000-8000-000000000007',
    'c0000000-0000-4000-8000-000000000008'
  );

-- Slides pointing at a course that is no longer for sale would lead nowhere.
update public.course_banners
set is_active = false
where course_id in (select id from public.courses where not is_published);
