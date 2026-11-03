-- Data and account deletion requests (Google Play's account-deletion policy).
--
-- A student asks — in the app, or on the website at /data-deletion — for one
-- of two things:
--
--   data     erase personal data and activity, keep the account and courses:
--            name, photo and school; doubts and comments; support tickets;
--            lecture ratings; notification and popup history; push tokens.
--   account  all of the above, then the sign-in itself (auth.users), which
--            removes the profile, enrolments and progress with it.
--
-- Orders and payments are kept either way, detached from the person, because
-- tax law requires transaction records to be retained. The request lands in
-- Admin → Deletion requests; a super admin approves or rejects it within
-- 3 days (`due_at`). Only a super admin can carry it out.

-- --------------------------------------------- keep orders, drop the link

alter table public.orders alter column student_id drop not null;
alter table public.orders drop constraint if exists orders_student_id_fkey;
alter table public.orders
  add constraint orders_student_id_fkey
  foreign key (student_id) references public.profiles (id) on delete set null;

-- ------------------------------------------------------------- requests

do $$ begin
  create type public.deletion_kind as enum ('data', 'account');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.deletion_status as enum ('pending', 'completed', 'rejected', 'cancelled');
exception when duplicate_object then null; end $$;

create table if not exists public.deletion_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles (id) on delete set null,
  kind public.deletion_kind not null,
  reason text check (char_length(reason) <= 1000),
  status public.deletion_status not null default 'pending',
  -- Who asked, captured at request time so the record still reads after the
  -- account is gone (masked once an account deletion completes).
  contact text,
  student_code text,
  requested_at timestamptz not null default now(),
  due_at timestamptz not null default now() + interval '3 days',
  processed_at timestamptz,
  processed_by uuid references public.profiles (id) on delete set null,
  admin_note text
);

-- One open request of each kind per person.
create unique index if not exists deletion_requests_one_pending
  on public.deletion_requests (user_id, kind) where status = 'pending';

alter table public.deletion_requests enable row level security;

drop policy if exists "deletion_requests_read" on public.deletion_requests;
create policy "deletion_requests_read"
on public.deletion_requests for select
using (user_id = auth.uid() or public.is_super_admin());
-- No insert/update/delete policies: every change goes through the functions
-- below, which check who is asking.

-- -------------------------------------------------------- student side

create or replace function public.request_deletion(p_kind public.deletion_kind, p_reason text default null)
returns public.deletion_requests
language plpgsql
security definer
set search_path = public
as $$
declare
  me public.profiles;
  existing public.deletion_requests;
  created public.deletion_requests;
begin
  if auth.uid() is null then
    raise exception 'Sign in to request deletion' using errcode = '42501';
  end if;
  select * into me from profiles where id = auth.uid();

  select * into existing from deletion_requests
  where user_id = auth.uid() and kind = p_kind and status = 'pending';
  if found then
    return existing;
  end if;

  insert into deletion_requests (user_id, kind, reason, contact, student_code)
  values (
    auth.uid(), p_kind, nullif(trim(p_reason), ''),
    coalesce(me.phone, me.email), me.student_code
  )
  returning * into created;
  return created;
end;
$$;

create or replace function public.cancel_deletion_request(p_id uuid)
returns void
language sql
security definer
set search_path = public
as $$
  update deletion_requests
  set status = 'cancelled', processed_at = now()
  where id = p_id and user_id = auth.uid() and status = 'pending';
$$;

-- ----------------------------------------------------- super admin side

-- Erase one person's personal data and activity; the account stays.
create or replace function public.erase_student_data(p_user uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  delete from lesson_comments where author_id = p_user;
  delete from community_messages where author_id = p_user;
  delete from community_members where student_id = p_user;
  delete from lesson_feedback where student_id = p_user;
  delete from tickets where student_id = p_user;          -- messages cascade
  delete from notifications where audience_student_id = p_user;
  delete from notification_reads where student_id = p_user;
  delete from popup_views where student_id = p_user;
  delete from device_tokens where user_id = p_user;
  update student_profiles set school = null where user_id = p_user;
  update profiles set full_name = '', avatar_url = null where id = p_user;
end;
$$;

revoke all on function public.erase_student_data(uuid) from public, anon, authenticated;

create or replace function public.process_deletion_request(
  p_id uuid,
  p_approve boolean,
  p_note text default null
)
returns public.deletion_requests
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  req public.deletion_requests;
begin
  if not public.is_super_admin() then
    raise exception 'Only a super admin can process deletion requests' using errcode = '42501';
  end if;

  select * into req from deletion_requests where id = p_id for update;
  if not found then
    raise exception 'Request not found' using errcode = 'P0002';
  end if;
  if req.status <> 'pending' then
    raise exception 'This request is already %', req.status using errcode = '22023';
  end if;
  if req.user_id = auth.uid() then
    raise exception 'Ask another super admin to process your own request' using errcode = '42501';
  end if;

  if p_approve and req.user_id is not null then
    perform public.erase_student_data(req.user_id);
    if req.kind = 'account' then
      -- Removes the sign-in; the profile, enrolments and progress cascade.
      -- Orders survive with student_id set to null.
      delete from auth.users where id = req.user_id;
    end if;
  end if;

  update deletion_requests
  set status = case when p_approve then 'completed' else 'rejected' end::public.deletion_status,
      processed_at = now(),
      processed_by = auth.uid(),
      admin_note = nullif(trim(p_note), ''),
      -- Once the account is gone, keep only enough to show the request existed.
      contact = case
        when p_approve and kind = 'account' and contact is not null
          then left(contact, 2) || '•••' || right(contact, 2)
        else contact
      end
  where id = p_id
  returning * into req;
  return req;
end;
$$;

revoke all on function public.process_deletion_request(uuid, boolean, text) from public, anon;
grant execute on function public.process_deletion_request(uuid, boolean, text) to authenticated;
revoke all on function public.request_deletion(public.deletion_kind, text) from public, anon;
grant execute on function public.request_deletion(public.deletion_kind, text) to authenticated;
revoke all on function public.cancel_deletion_request(uuid) from public, anon;
grant execute on function public.cancel_deletion_request(uuid) to authenticated;

grant select on public.deletion_requests to authenticated;
