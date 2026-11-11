-- Migration 17: security hardening before launch (audit of 11 Nov 2026).
--
-- Each block closes one finding. Safe to re-run.
--
--   1. Live class stream ids were readable by anyone, enrolled or not.
--   2. A student could change the phone/email on their own profile — the
--      values stamped on videos and notes as the anti-sharing watermark.
--   3. A student could post a ticket message marked "from support", or as
--      another author.
--   4. A student could open a ticket already "resolved" or assigned.
--   5. Lecture comments were readable by anyone on the internet, and any
--      account could comment on lectures it cannot watch.
--   6. The community-members policy referred to itself, and let any student
--      list the ids of every other student.
--   7. Teachers could read every order and payment; that is meant to be
--      super-admin only.
--   8. An expired enrolment still listed paid lessons and notes.
--   9. Refunds: a function the payment webhook calls to revoke access.

-- ============================================== 1. live class stream ids

-- The schedule (title, time, status) stays public, as the app's Live tab and
-- the website show it. The stream ids are removed from ordinary reads; an
-- enrolled student gets them from live_session_join() when they join.
revoke select on public.live_sessions from anon, authenticated;

grant select (
  id,
  batch_id,
  subject_id,
  chapter_id,
  teacher_id,
  title,
  description,
  starts_at,
  ends_at,
  provider,
  status,
  recording_lesson_id,
  created_at
) on public.live_sessions to anon, authenticated;

create or replace function public.live_session_join(p_session_id uuid)
returns table (provider public.live_provider, youtube_video_id text, jitsi_room_id text, recording_url text)
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  s record;
begin
  select ls.provider, ls.youtube_video_id, ls.jitsi_room_id, ls.recording_url, b.course_id
    into s
  from live_sessions ls
  join course_batches b on b.id = ls.batch_id
  where ls.id = p_session_id;

  if not found then
    return;
  end if;

  if not (
    public.is_staff()
    or exists (
      select 1 from enrollments e
      where e.student_id = auth.uid()
        and e.course_id = s.course_id
        and e.status = 'active'
        and (e.expires_at is null or e.expires_at > now())
    )
  ) then
    raise exception 'not_entitled' using errcode = '42501';
  end if;

  return query select s.provider, s.youtube_video_id, s.jitsi_room_id, s.recording_url;
end;
$$;

revoke all on function public.live_session_join(uuid) from public, anon;
grant execute on function public.live_session_join(uuid) to authenticated;

-- The admin console's view of the same columns.
create or replace function public.staff_live_media()
returns table (id uuid, youtube_video_id text, jitsi_room_id text, recording_url text)
language sql
stable
security definer
set search_path = public
as $$
  select ls.id, ls.youtube_video_id, ls.jitsi_room_id, ls.recording_url
  from live_sessions ls
  where public.is_staff();
$$;

revoke all on function public.staff_live_media() from public, anon;
grant execute on function public.staff_live_media() to authenticated;

-- ===================================== 2. watermark identity on profiles

-- phone and email come from the sign-in (auth.users) and are what the
-- watermark shows. Only an admin, or the service role, may change them.
create or replace function public.protect_profile_identity()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is not null and not public.is_admin() then
    if new.phone is distinct from old.phone or new.email is distinct from old.email then
      raise exception 'Phone and email cannot be changed here' using errcode = '42501';
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists profiles_protect_identity on public.profiles;
create trigger profiles_protect_identity
before update on public.profiles
for each row execute function public.protect_profile_identity();

-- The own-row update policy had no WITH CHECK; make it explicit.
drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own"
on public.profiles for update
using (auth.uid() = id)
with check (auth.uid() = id);

-- ================================================== 3. ticket messages

drop policy if exists "ticket_messages_write" on public.ticket_messages;
create policy "ticket_messages_write"
on public.ticket_messages for insert
with check (
  public.is_staff()
  or (
    author_id = auth.uid()
    and from_support = false
    and exists (
      select 1 from public.tickets t
      where t.id = public.ticket_messages.ticket_id
        and t.student_id = auth.uid()
        and t.status <> 'closed'
    )
  )
);

-- ========================================================== 4. tickets

drop policy if exists "tickets_student_create" on public.tickets;
create policy "tickets_student_create"
on public.tickets for insert
with check (
  student_id = auth.uid()
  and status = 'open'
  and assigned_to is null
);

-- ================================================= 5. lecture comments

-- Whether the caller may watch a lesson: the same rule as lesson_playback().
create or replace function public.can_view_lesson(p_lesson_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.is_staff() or exists (
    select 1
    from lessons l
    join chapters ch on ch.id = l.chapter_id
    join subjects s on s.id = ch.subject_id
    join course_batches b on b.id = s.batch_id
    where l.id = p_lesson_id
      and l.is_published
      and (
        l.is_demo
        or exists (
          select 1 from enrollments e
          where e.student_id = auth.uid()
            and e.course_id = b.course_id
            and e.status = 'active'
            and (e.expires_at is null or e.expires_at > now())
        )
      )
  );
$$;

revoke all on function public.can_view_lesson(uuid) from public;
grant execute on function public.can_view_lesson(uuid) to anon, authenticated;

drop policy if exists "lesson_comments_read" on public.lesson_comments;
create policy "lesson_comments_read"
on public.lesson_comments for select
using (auth.uid() is not null and public.can_view_lesson(lesson_id));

-- A student posts as themselves, on a lesson they can watch, and cannot
-- pre-mark a doubt as answered.
drop policy if exists "lesson_comments_write" on public.lesson_comments;
create policy "lesson_comments_write"
on public.lesson_comments for insert
with check (
  author_id = auth.uid()
  and (
    public.is_staff()
    or (
      public.can_view_lesson(lesson_id)
      and is_resolved = false
      and resolved_by is null
    )
  )
);

drop policy if exists "lesson_comments_author_update" on public.lesson_comments;
create policy "lesson_comments_author_update"
on public.lesson_comments for update
using (author_id = auth.uid() or public.is_staff())
with check (author_id = auth.uid() or public.is_staff());

-- ============================================== 6. community members

-- The old policy looked up community_members from inside its own policy.
-- A student now sees only their own memberships; every account is in the
-- free demo course's community, so "fellow members" meant every student id.
drop policy if exists "community_members_read" on public.community_members;
create policy "community_members_read"
on public.community_members for select
using (public.is_staff() or student_id = auth.uid());

-- ============================================ 7. orders and payments

-- Own rows, or the super admin (orders_super_admin_read / payments_super_admin_read).
drop policy if exists "orders_select_own" on public.orders;
create policy "orders_select_own"
on public.orders for select
using (auth.uid() = student_id);

drop policy if exists "payments_select_own" on public.payments;
create policy "payments_select_own"
on public.payments for select
using (
  exists (
    select 1 from public.orders o
    where o.id = order_id and o.student_id = auth.uid()
  )
);

-- ======================================== 8. expired enrolments

drop policy if exists "lessons_demo_or_staff_read" on public.lessons;
create policy "lessons_demo_or_staff_read"
on public.lessons for select
using (
  public.is_staff()
  or (is_published = true and is_demo = true)
  or (
    is_published = true
    and exists (
      select 1
      from public.chapters ch
      join public.subjects s on s.id = ch.subject_id
      join public.course_batches b on b.id = s.batch_id
      join public.enrollments e on e.course_id = b.course_id
      where ch.id = chapter_id
        and e.student_id = auth.uid()
        and e.status = 'active'
        and (e.expires_at is null or e.expires_at > now())
    )
  )
);

drop policy if exists "lesson_resources_read" on public.lesson_resources;
create policy "lesson_resources_read"
on public.lesson_resources for select
using (
  public.is_staff()
  or exists (
    select 1
    from public.lessons l
    where l.id = public.lesson_resources.lesson_id
      and l.is_published = true
      and (
        l.is_demo = true
        or exists (
          select 1
          from public.chapters ch
          join public.subjects s on s.id = ch.subject_id
          join public.course_batches b on b.id = s.batch_id
          join public.enrollments e on e.course_id = b.course_id
          where ch.id = l.chapter_id
            and e.student_id = auth.uid()
            and e.status = 'active'
            and (e.expires_at is null or e.expires_at > now())
        )
      )
  )
);

-- ==================================================== 9. refunds

-- Called by the payment webhook (service role) when Razorpay reports a full
-- refund: the order is marked refunded and access to the course ends.
create or replace function public.revoke_refunded_order(p_razorpay_payment_id text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  o record;
begin
  select id, student_id, course_id into o
  from orders
  where razorpay_payment_id = p_razorpay_payment_id;
  if not found then
    return null;
  end if;

  update orders set status = 'refunded' where id = o.id;
  update payments set status = 'refunded' where razorpay_payment_id = p_razorpay_payment_id;

  if o.student_id is not null then
    update enrollments
    set status = 'refunded'
    where student_id = o.student_id and course_id = o.course_id and status = 'active';
  end if;
  return o.id;
end;
$$;

revoke all on function public.revoke_refunded_order(text) from public, anon, authenticated;
grant execute on function public.revoke_refunded_order(text) to service_role;
