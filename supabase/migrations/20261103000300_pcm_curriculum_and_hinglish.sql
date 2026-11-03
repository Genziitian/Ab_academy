-- Migration 15: curriculum skeleton for the three PCM crash courses, and
-- Hinglish as a study language.
--
-- Each chapter of a crash course has exactly two lessons: one lecture and one
-- practice session. They are created empty and unpublished; staff add the
-- video in Admin → Content and publish it, and only then do students see it.
-- Ids are derived from the course and chapter number, so re-running this
-- file changes nothing.

-- ------------------------------------------------------------- language
alter table public.student_profiles
  drop constraint if exists student_profiles_medium_check;
alter table public.student_profiles
  add constraint student_profiles_medium_check
  check (medium in ('Hindi', 'Hinglish', 'English'));

-- ------------------------------------------------------------- batches
insert into public.course_batches (id, course_id, name, starts_on, ends_on) values
  ('ba000000-0000-4000-8000-000000000007', 'c0000000-0000-4000-8000-000000000007', '2027 Board Batch', '2026-11-16', '2027-03-31'),
  ('ba000000-0000-4000-8000-000000000008', 'c0000000-0000-4000-8000-000000000008', '2027 Board Batch', '2026-11-16', '2027-03-31')
on conflict do nothing;

insert into public.subjects (id, batch_id, name, sort_order) values
  ('ba000000-0000-4000-8000-000000000017', 'ba000000-0000-4000-8000-000000000007', 'Chemistry', 1),
  ('ba000000-0000-4000-8000-000000000018', 'ba000000-0000-4000-8000-000000000008', 'Mathematics', 1)
on conflict do nothing;

-- ------------------------------------------------------------- chapters
with syllabus(subject_id, chapters) as (
  values
    ('ba000000-0000-4000-8000-000000000012'::uuid, array[
      'Electric Charges & Fields', 'Electrostatic Potential', 'Current Electricity',
      'Moving Charges & Magnetism', 'Magnetism & Matter', 'Electromagnetic Induction',
      'Alternating Current', 'Electromagnetic Waves', 'Ray Optics', 'Wave Optics',
      'Dual Nature of Matter', 'Atoms', 'Nuclei', 'Semiconductors']),
    ('ba000000-0000-4000-8000-000000000017'::uuid, array[
      'Solutions', 'Electrochemistry', 'Chemical Kinetics', 'd- & f-Block Elements',
      'Coordination Compounds', 'Haloalkanes & Haloarenes', 'Alcohols, Phenols & Ethers',
      'Aldehydes & Ketones', 'Amines', 'Biomolecules']),
    ('ba000000-0000-4000-8000-000000000018'::uuid, array[
      'Relations & Functions', 'Inverse Trigonometry', 'Matrices', 'Determinants',
      'Continuity & Differentiability', 'Applications of Derivatives', 'Integrals',
      'Applications of Integrals', 'Differential Equations', 'Vectors', '3D Geometry',
      'Linear Programming', 'Probability'])
),
rows as (
  select s.subject_id, c.title, c.ord::int as ord,
         md5('ab-chapter:' || s.subject_id || ':' || c.ord)::uuid as chapter_id
  from syllabus s
  cross join lateral unnest(s.chapters) with ordinality as c(title, ord)
),
ins_chapters as (
  insert into public.chapters (id, subject_id, title, sort_order)
  select chapter_id, subject_id, title, ord from rows
  on conflict (id) do update set title = excluded.title, sort_order = excluded.sort_order
  returning id
)
insert into public.lessons (id, chapter_id, title, lesson_type, sort_order, is_demo, is_published)
select md5('ab-lesson:' || r.chapter_id || ':' || k.n)::uuid,
       r.chapter_id,
       case k.n when 1 then 'Lecture — ' || r.title else 'Practice session — ' || r.title end,
       'VIDEO',
       k.n,
       false,
       false
from rows r
cross join (values (1), (2)) as k(n)
where exists (select 1 from ins_chapters)
on conflict (id) do nothing;

-- Lesson counts on the course cards: two per chapter.
update public.courses set lessons_count = 28 where id = 'c0000000-0000-4000-8000-000000000002';
update public.courses set lessons_count = 20 where id = 'c0000000-0000-4000-8000-000000000007';
update public.courses set lessons_count = 26 where id = 'c0000000-0000-4000-8000-000000000008';
