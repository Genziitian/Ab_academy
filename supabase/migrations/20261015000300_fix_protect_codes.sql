-- Migration 10: fix protect_codes() from migration 8.
--
-- PL/pgSQL resolves `new.course_code` even when the table check before it is
-- false, so every profile update failed with "record new has no field
-- course_code". Nesting the checks means each field is read only on its table.
create or replace function public.protect_codes()
returns trigger
language plpgsql
as $$
begin
  if tg_table_name = 'courses' then
    if new.course_code is distinct from old.course_code then
      raise exception 'course_code cannot be changed' using errcode = '42501';
    end if;
  elsif tg_table_name = 'profiles' then
    if new.student_code is distinct from old.student_code then
      raise exception 'student_code cannot be changed' using errcode = '42501';
    end if;
  end if;
  return new;
end;
$$;
