-- Migration 7: class notes hosted on Google Drive, read only inside the app.
--
-- A note (lesson_resources row) now comes from either the private
-- `lesson-notes` bucket (source = 'storage') or a Google Drive file
-- (source = 'gdrive'). Either way the app never learns where the file
-- lives: it asks the `notes` Edge Function for a resource id, the function
-- checks access through `note_access()` as the student, fetches the PDF
-- server-side and streams the bytes back. The Drive file id and the storage
-- path are not selectable by students.

alter table public.lesson_resources
  alter column storage_path drop not null,
  add column if not exists source text not null default 'storage',
  add column if not exists drive_file_id text;

alter table public.lesson_resources
  drop constraint if exists lesson_resources_source_check;
alter table public.lesson_resources
  add constraint lesson_resources_source_check check (
    (source = 'storage' and storage_path is not null)
    or (source = 'gdrive' and drive_file_id is not null)
  );

-- ------------------------------------------------- column-level privileges

revoke select on public.lesson_resources from anon, authenticated;

grant select (
  id,
  lesson_id,
  title,
  resource_type,
  size_bytes,
  is_downloadable,
  source,
  created_at
) on public.lesson_resources to anon, authenticated;

-- ------------------------------------------------------------ access check

-- Where a note's file lives, for the `notes` Edge Function. Called with the
-- student's own token, so auth.uid() is the student. Returns no row when the
-- note does not exist; raises 42501 when the student may not read it.
create or replace function public.note_access(p_resource_id uuid)
returns table (source text, storage_path text, drive_file_id text, title text)
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  r record;
begin
  select lr.source, lr.storage_path, lr.drive_file_id, lr.title,
         l.is_demo, l.is_published, b.course_id
    into r
  from lesson_resources lr
  join lessons l on l.id = lr.lesson_id
  join chapters ch on ch.id = l.chapter_id
  join subjects s on s.id = ch.subject_id
  join course_batches b on b.id = s.batch_id
  where lr.id = p_resource_id;

  if not found then
    return;
  end if;

  if not (
    public.is_staff()
    or (r.is_published and r.is_demo)
    or (
      r.is_published
      and exists (
        select 1 from enrollments e
        where e.student_id = auth.uid()
          and e.course_id = r.course_id
          and e.status = 'active'
          and (e.expires_at is null or e.expires_at > now())
      )
    )
  ) then
    raise exception 'not_entitled' using errcode = '42501';
  end if;

  return query select r.source, r.storage_path, r.drive_file_id, r.title;
end;
$$;

revoke all on function public.note_access(uuid) from public;
grant execute on function public.note_access(uuid) to authenticated;

-- ------------------------------------------------------- admin console

create or replace function public.staff_resource_media()
returns table (id uuid, source text, storage_path text, drive_file_id text)
language sql
stable
security definer
set search_path = public
as $$
  select lr.id, lr.source, lr.storage_path, lr.drive_file_id
  from lesson_resources lr
  where public.is_staff();
$$;

revoke all on function public.staff_resource_media() from public;
grant execute on function public.staff_resource_media() to authenticated;
