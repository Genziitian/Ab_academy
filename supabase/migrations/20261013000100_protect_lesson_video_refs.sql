-- Migration 6: keep lecture video references out of students' hands.
--
-- Lectures are hosted as unlisted YouTube videos. Anyone who learns a video's
-- id can watch it on youtube.com without paying, so the id must not travel
-- with ordinary reads. Until now `lessons.video_ref` came back with every
-- curriculum query (and with demo lessons, to anyone at all).
--
-- After this migration:
--   * students and anonymous visitors cannot select `video_ref` or
--     `storage_path` at all — the columns are left out of their grant;
--   * the app asks `lesson_playback(lesson_id)` for one video at the moment
--     it plays it, and gets it only if the lesson is a published demo or the
--     student holds an active, unexpired enrolment in that course;
--   * staff read the columns through `staff_lesson_media()` for the console.
--
-- Note this cannot make an unlisted video secret from a determined student
-- who inspects network traffic while it plays; it removes every other path.

-- ------------------------------------------------- column-level privileges

revoke select on public.lessons from anon, authenticated;

grant select (
  id,
  chapter_id,
  title,
  lesson_type,
  sort_order,
  duration_seconds,
  video_provider,
  is_demo,
  is_published,
  created_at,
  thumbnail_path,
  is_downloadable
) on public.lessons to anon, authenticated;

-- Writes are unchanged: RLS (lessons_staff_write) still decides who may
-- insert, update or delete, and those statements may set video_ref.

-- ------------------------------------------------------------- playback

create or replace function public.lesson_playback(p_lesson_id uuid)
returns table (provider text, video_ref text)
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_lesson record;
  v_course uuid;
begin
  select l.id, l.video_provider, l.video_ref, l.is_demo, l.is_published, b.course_id
    into v_lesson
  from lessons l
  join chapters ch on ch.id = l.chapter_id
  join subjects s on s.id = ch.subject_id
  join course_batches b on b.id = s.batch_id
  where l.id = p_lesson_id;

  if not found then
    return;
  end if;
  v_course := v_lesson.course_id;

  if not (
    public.is_staff()
    or (v_lesson.is_published and v_lesson.is_demo)
    or (
      v_lesson.is_published
      and exists (
        select 1 from enrollments e
        where e.student_id = auth.uid()
          and e.course_id = v_course
          and e.status = 'active'
          and (e.expires_at is null or e.expires_at > now())
      )
    )
  ) then
    raise exception 'not_entitled' using errcode = '42501';
  end if;

  return query select v_lesson.video_provider, v_lesson.video_ref;
end;
$$;

revoke all on function public.lesson_playback(uuid) from public;
grant execute on function public.lesson_playback(uuid) to anon, authenticated;

-- ------------------------------------------------------- admin console

create or replace function public.staff_lesson_media()
returns table (id uuid, video_ref text, storage_path text)
language sql
stable
security definer
set search_path = public
as $$
  select l.id, l.video_ref, l.storage_path
  from lessons l
  where public.is_staff();
$$;

revoke all on function public.staff_lesson_media() from public;
grant execute on function public.staff_lesson_media() to authenticated;
