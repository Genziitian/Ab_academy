-- Migration 9: the launch catalog, with free demo lectures and notes.
--
-- Six crash courses (the same catalog the website shows), one batch each, a
-- subject row per subject, and demo lessons in Class 11 and Class 12 Science
-- Mathematics. The lectures are Gen-Z IITian videos on YouTube
-- (youtube.com/@Gen-ZIITian) and the notes are PDFs on Google Drive, so both
-- play through the secure player and the `notes` function like any upload.
--
-- Fixed ids and `on conflict do nothing` make this safe to re-run and never
-- overwrite edits made in the admin console afterwards.

-- ------------------------------------------------------------- teachers

insert into public.teachers (id, display_name, bio, subjects) values
  ('7e000000-0000-4000-8000-000000000001', 'Senior Faculty',
   'Subject specialists for Physics, Chemistry, Mathematics and Biology, teaching to the Bihar Board Class 12 pattern.',
   '{Physics,Chemistry,Mathematics,Biology}'),
  ('7e000000-0000-4000-8000-000000000002', 'Amit Sir',
   'Amit Sir focuses on concept clarity, derivations and numericals in the Bihar Board Class 12 pattern.',
   '{Physics}'),
  ('7e000000-0000-4000-8000-000000000003', 'Ravi Sir',
   'Ravi Sir teaches Accountancy, Business Studies and Economics with solved board papers and numerical drills.',
   '{Accountancy,"Business Studies",Economics}'),
  ('7e000000-0000-4000-8000-000000000004', 'Faculty Team',
   'A humanities team covering History, Political Science and Geography with map work and answer-writing practice.',
   '{History,"Political Science",Geography}'),
  ('7e000000-0000-4000-8000-000000000005', 'Neha Ma''am',
   'Neha Ma''am builds Class 11 Science foundations so Class 12 and entrance prep feel manageable.',
   '{Physics,Chemistry,Mathematics,Biology}')
on conflict do nothing;

-- -------------------------------------------------------------- courses

insert into public.courses (
  id, slug, title, description, class_level, language, thumbnail_hue,
  price_inr, original_price_inr, rating, lessons_count, highlights, subjects,
  is_published
) values
  ('c0000000-0000-4000-8000-000000000001', 'class-12-science-crash-course-2027',
   'Class 12 Science Crash Course 2027',
   'Complete Class 12 Science revision in 90 days with live classes, chapter recordings, notes and board-pattern tests.',
   12, 'Hindi + English', 214, 2499, 4999, 4.8, 120,
   '{"Live classes with expert teachers","Recorded lectures you can revise anytime","PDF notes for every chapter","Weekly board-pattern tests"}',
   '{Physics,Chemistry,Mathematics,Biology}', true),
  ('c0000000-0000-4000-8000-000000000002', 'class-12-physics-crash-course',
   'Class 12 Physics Crash Course',
   'Electrostatics to Semiconductors with numericals, derivations and important board questions.',
   12, 'Hindi', 198, 999, 1799, 4.9, 48,
   '{"Chapter-wise live + recorded classes","Important questions for board exams","Formula sheets and PDF notes","Progress tracking per chapter"}',
   '{Physics}', true),
  ('c0000000-0000-4000-8000-000000000003', 'class-12-commerce-crash-course',
   'Class 12 Commerce Crash Course',
   'Fast revision of Accountancy, Business Studies and Economics with solved board papers.',
   12, 'Hindi', 320, 1999, 3499, 4.7, 90,
   '{"Numerical practice for Accountancy","Chapter-wise recordings","Study notes in Hindi","Solved board papers"}',
   '{Accountancy,"Business Studies",Economics}', true),
  ('c0000000-0000-4000-8000-000000000004', 'class-12-arts-crash-course',
   'Class 12 Arts Crash Course',
   'Chapter summaries, map work and answer-writing practice for Class 12 Arts boards.',
   12, 'Hindi', 28, 1799, 2999, 4.6, 80,
   '{"Chapter summaries","Map work practice","Answer-writing sessions","Hindi notes"}',
   '{History,"Political Science",Geography}', true),
  ('c0000000-0000-4000-8000-000000000005', 'class-11-science-crash-course',
   'Class 11 Science Crash Course',
   'Cover Class 11 Science quickly so Class 12 and entrance prep feel manageable.',
   11, 'Hindi + English', 162, 1999, 3499, 4.7, 100,
   '{"Concept-first teaching","Numerical practice","Chapter notes","Live doubt sessions"}',
   '{Physics,Chemistry,Mathematics,Biology}', true),
  ('c0000000-0000-4000-8000-000000000006', 'class-11-commerce-crash-course',
   'Class 11 Commerce Crash Course',
   'Clear Class 11 Commerce concepts with numerical practice and Hindi notes.',
   11, 'Hindi', 250, 1499, 2499, 4.5, 72,
   '{"Concept + numerical practice","Chapter-wise recordings","Study notes in Hindi","Scheduled live classes"}',
   '{Accountancy,"Business Studies",Economics}', true)
on conflict do nothing;

insert into public.course_teachers (course_id, teacher_id, is_primary) values
  ('c0000000-0000-4000-8000-000000000001', '7e000000-0000-4000-8000-000000000001', true),
  ('c0000000-0000-4000-8000-000000000002', '7e000000-0000-4000-8000-000000000002', true),
  ('c0000000-0000-4000-8000-000000000003', '7e000000-0000-4000-8000-000000000003', true),
  ('c0000000-0000-4000-8000-000000000004', '7e000000-0000-4000-8000-000000000004', true),
  ('c0000000-0000-4000-8000-000000000005', '7e000000-0000-4000-8000-000000000005', true),
  ('c0000000-0000-4000-8000-000000000006', '7e000000-0000-4000-8000-000000000003', true)
on conflict do nothing;

-- ------------------------------------------------------------- batches

insert into public.course_batches (id, course_id, name, starts_on, ends_on) values
  ('ba000000-0000-4000-8000-000000000001', 'c0000000-0000-4000-8000-000000000001', '2027 Board Batch', '2026-10-01', '2027-03-31'),
  ('ba000000-0000-4000-8000-000000000002', 'c0000000-0000-4000-8000-000000000002', '2027 Board Batch', '2026-10-01', '2027-03-31'),
  ('ba000000-0000-4000-8000-000000000003', 'c0000000-0000-4000-8000-000000000003', '2027 Board Batch', '2026-10-01', '2027-03-31'),
  ('ba000000-0000-4000-8000-000000000004', 'c0000000-0000-4000-8000-000000000004', '2027 Board Batch', '2026-10-01', '2027-03-31'),
  ('ba000000-0000-4000-8000-000000000005', 'c0000000-0000-4000-8000-000000000005', '2026–27 Session', '2026-10-01', '2027-03-31'),
  ('ba000000-0000-4000-8000-000000000006', 'c0000000-0000-4000-8000-000000000006', '2026–27 Session', '2026-10-01', '2027-03-31')
on conflict do nothing;

-- One subject row per subject in each course, in catalog order. Ids are
-- derived from the batch so re-runs line up.
insert into public.subjects (id, batch_id, name, sort_order)
select
  (left(b.id::text, 24) || lpad(to_hex(s.ord::int * 16 + right(b.id::text, 1)::int), 12, '0'))::uuid
    as id,
  b.id,
  s.name,
  s.ord::int
from public.course_batches b
join public.courses c on c.id = b.course_id
cross join lateral unnest(c.subjects) with ordinality as s(name, ord)
where b.id::text like 'ba000000-0000-4000-8000-%'
on conflict do nothing;

-- --------------------------------------------------- demo chapters

-- Class 11 Science → Mathematics is subject 3 of batch 5; Class 12 Science →
-- Mathematics is subject 3 of batch 1 (see the id scheme above).
insert into public.chapters (id, subject_id, title, sort_order) values
  ('c4000000-0000-4000-8000-000000000001', 'ba000000-0000-4000-8000-000000000035', 'Sets, Relations and Functions', 1),
  ('c4000000-0000-4000-8000-000000000002', 'ba000000-0000-4000-8000-000000000035', 'Statistics', 2),
  ('c4000000-0000-4000-8000-000000000003', 'ba000000-0000-4000-8000-000000000031', 'Matrices and Vectors', 1),
  ('c4000000-0000-4000-8000-000000000004', 'ba000000-0000-4000-8000-000000000031', 'Determinants and Linear Equations', 2)
on conflict do nothing;

-- ------------------------------------------------------ demo lessons

insert into public.lessons (
  id, chapter_id, title, lesson_type, sort_order, duration_seconds,
  video_provider, video_ref, is_demo, is_published
) values
  ('1e000000-0000-4000-8000-000000000001', 'c4000000-0000-4000-8000-000000000001',
   'Sets, Relations & Functions — Detailed Theory', 'VIDEO', 1, 2375,
   'youtube', 'TuK415Wz0Q0', true, true),
  ('1e000000-0000-4000-8000-000000000002', 'c4000000-0000-4000-8000-000000000001',
   'Class notes · Functions practice', 'PDF', 2, null,
   null, null, true, true),
  ('1e000000-0000-4000-8000-000000000003', 'c4000000-0000-4000-8000-000000000002',
   'Statistics — Detailed Hindi Lecture', 'VIDEO', 1, 2477,
   'youtube', '2Pf9oKazhiQ', true, true),
  ('1e000000-0000-4000-8000-000000000004', 'c4000000-0000-4000-8000-000000000003',
   'Vectors & Matrices', 'VIDEO', 1, 4325,
   'youtube', 'W76RnM-86DE', true, true),
  ('1e000000-0000-4000-8000-000000000005', 'c4000000-0000-4000-8000-000000000004',
   'Linear Equations & Determinants', 'VIDEO', 1, 3109,
   'youtube', 'Nd48fIotQyo', true, true)
on conflict do nothing;

-- Notes live on Google Drive; the `notes` Edge Function streams them into the
-- in-app viewer, so the Drive links never reach the app.
insert into public.lesson_resources (
  id, lesson_id, title, resource_type, source, drive_file_id, size_bytes,
  is_downloadable
) values
  ('2e000000-0000-4000-8000-000000000001', '1e000000-0000-4000-8000-000000000001',
   'Logarithmic Functions — Exercises', 'PDF', 'gdrive',
   '13vVIe_8WNGfxhE67JWJJEeaNpwvjCaZ2', 240640, false),
  ('2e000000-0000-4000-8000-000000000002', '1e000000-0000-4000-8000-000000000002',
   'Maths 1 · Week 5 Notes', 'PDF', 'gdrive',
   '1Q4zw5HKVBD2qqYYy-BEt17mvIhguGiik', 6050000, false)
on conflict do nothing;
