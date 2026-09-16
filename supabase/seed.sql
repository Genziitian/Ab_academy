-- Seed catalog for Akhand Bharat Academy (Bihar Board first wave)

insert into public.teachers (id, display_name, bio, subjects)
values
  ('11111111-1111-1111-1111-111111111101', 'Amit Sir', 'Mathematics faculty', array['Mathematics']),
  ('11111111-1111-1111-1111-111111111102', 'Priya Ma''am', 'Science faculty', array['Science']),
  ('11111111-1111-1111-1111-111111111103', 'Ravi Sir', 'Commerce faculty', array['Accountancy','Business Studies','Economics']),
  ('11111111-1111-1111-1111-111111111104', 'Faculty Team', 'Multi-subject faculty', array['General']);

insert into public.courses (
  id, slug, title, description, board, class_level, language,
  thumbnail_hue, price_inr, original_price_inr, rating, lessons_count,
  highlights, subjects, is_published
) values
(
  '22222222-2222-2222-2222-222222222201',
  'class-10-complete-batch-2027',
  'Class 10 Complete Batch 2027',
  'A complete Class 10 programme with live classes, recordings, notes and chapter-wise practice — currently aligned to Bihar Board.',
  'Bihar Board', 10, 'Hindi + English', 214, 1999, 3499, 4.8, 120,
  array[
    'Live classes with expert teachers',
    'Recorded lectures you can revise anytime',
    'PDF notes for every chapter',
    'Weekly doubt support and scheduled tests'
  ],
  array['Mathematics','Science','Hindi','English','Social Science'],
  true
),
(
  '22222222-2222-2222-2222-222222222202',
  'class-10-mathematics',
  'Class 10 Mathematics',
  'Focused Mathematics batch covering Real Numbers to Probability with board-oriented problem solving.',
  'Bihar Board', 10, 'Hindi', 198, 799, 1299, 4.9, 48,
  array[
    'Chapter-wise live + recorded classes',
    'Important questions for board exams',
    'Formula sheets and PDF notes',
    'Progress tracking per chapter'
  ],
  array['Mathematics'],
  true
),
(
  '22222222-2222-2222-2222-222222222203',
  'class-10-science',
  'Class 10 Science',
  'Physics, Chemistry and Biology taught in a simple, exam-focused way with diagrams, notes and revision classes.',
  'Bihar Board', 10, 'Hindi + English', 162, 899, 1499, 4.7, 56,
  array[
    'Concept-first teaching',
    'Diagram practice and numericals',
    'Chapter notes and PYQ discussions',
    'Live revision before exams'
  ],
  array['Physics','Chemistry','Biology'],
  true
),
(
  '22222222-2222-2222-2222-222222222204',
  'class-9-foundation',
  'Class 9 Foundation Batch',
  'Build Class 9 foundations early so Class 10 feels manageable and confident.',
  'Bihar Board', 9, 'Hindi', 250, 1499, 2499, 4.6, 90,
  array[
    'Daily live classes for core subjects',
    'Recordings for missed sessions',
    'Homework worksheets and notes',
    'Clear weekly learning plan'
  ],
  array['Mathematics','Science','English','Hindi'],
  true
),
(
  '22222222-2222-2222-2222-222222222205',
  'class-12-science-complete',
  'Class 12 Science Complete',
  'Full Class 12 Science batch with board + entrance oriented practice.',
  'Bihar Board', 12, 'English + Hindi', 28, 3999, 5999, 4.8, 160,
  array[
    'Subject specialists for PCM/PCB',
    'Board pattern tests',
    'Notes and formula banks',
    'Live doubt sessions'
  ],
  array['Physics','Chemistry','Mathematics / Biology'],
  true
),
(
  '22222222-2222-2222-2222-222222222206',
  'class-11-commerce',
  'Class 11 Commerce Starter',
  'Clear Accountancy, BST and Economics concepts with aligned lessons and notes.',
  'Bihar Board', 11, 'Hindi', 320, 1799, 2799, 4.5, 72,
  array[
    'Concept + numerical practice',
    'Chapter-wise recordings',
    'Study notes in Hindi',
    'Scheduled live classes'
  ],
  array['Accountancy','Business Studies','Economics'],
  true
);

insert into public.course_teachers (course_id, teacher_id, is_primary) values
  ('22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111104', true),
  ('22222222-2222-2222-2222-222222222202', '11111111-1111-1111-1111-111111111101', true),
  ('22222222-2222-2222-2222-222222222203', '11111111-1111-1111-1111-111111111102', true),
  ('22222222-2222-2222-2222-222222222204', '11111111-1111-1111-1111-111111111104', true),
  ('22222222-2222-2222-2222-222222222205', '11111111-1111-1111-1111-111111111104', true),
  ('22222222-2222-2222-2222-222222222206', '11111111-1111-1111-1111-111111111103', true);

insert into public.course_batches (id, course_id, name, starts_on, is_active) values
  ('33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '2027 Board Batch', '2026-04-01', true),
  ('33333333-3333-3333-3333-333333333302', '22222222-2222-2222-2222-222222222202', '2027 Board Batch', '2026-04-01', true),
  ('33333333-3333-3333-3333-333333333303', '22222222-2222-2222-2222-222222222203', '2027 Board Batch', '2026-04-01', true);

insert into public.subjects (id, batch_id, name, sort_order) values
  ('44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333302', 'Mathematics', 1);

insert into public.chapters (id, subject_id, title, sort_order) values
  ('55555555-5555-5555-5555-555555555501', '44444444-4444-4444-4444-444444444401', 'Real Numbers', 1);

insert into public.lessons (chapter_id, title, lesson_type, sort_order, is_demo, is_published) values
  ('55555555-5555-5555-5555-555555555501', 'Introduction (Demo)', 'VIDEO', 1, true, true),
  ('55555555-5555-5555-5555-555555555501', 'Euclid Division Lemma', 'VIDEO', 2, false, true);
