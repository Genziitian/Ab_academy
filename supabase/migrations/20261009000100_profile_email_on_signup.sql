-- Google sign-in: store the email the provider gives us.
--
-- 20260917000100 added `profiles.email` and a unique index on it, but left
-- `handle_new_user()` inserting only phone/name/avatar — so every OAuth signup
-- landed with a null email and the index had nothing to enforce. Fill it here.

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, phone, email, full_name, avatar_url, role)
  values (
    new.id,
    new.phone,
    -- Phone-OTP signups have no email at all; keep it null rather than ''
    -- so the partial unique index ignores them.
    nullif(lower(coalesce(new.email, '')), ''),
    coalesce(
      new.raw_user_meta_data->>'full_name',
      new.raw_user_meta_data->>'name',
      ''
    ),
    coalesce(
      new.raw_user_meta_data->>'avatar_url',
      new.raw_user_meta_data->>'picture'
    ),
    'student'
  )
  on conflict (id) do nothing;

  insert into public.student_profiles (user_id)
  values (new.id)
  on conflict (user_id) do nothing;

  return new;
end;
$$;

-- Backfill anyone who signed up before this ran.
update public.profiles p
set email = nullif(lower(coalesce(u.email, '')), '')
from auth.users u
where u.id = p.id
  and p.email is null
  and u.email is not null;
