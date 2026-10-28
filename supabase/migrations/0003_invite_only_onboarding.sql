-- Invite-only onboarding. Review in a disposable Supabase project before applying.
-- Supabase projects provide the extensions schema for trusted extensions.
create extension if not exists pgcrypto with schema extensions;

create table public.platform_admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);
alter table public.platform_admins enable row level security;
revoke all on public.platform_admins from anon, authenticated;

create table public.school_invitations (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools(id) on delete cascade,
  email text not null check (length(trim(email)) between 3 and 320 and position('@' in email) > 1),
  role public.school_role not null check (role in ('owner','admin','registrar','teacher','viewer')),
  token_hash text not null unique check (token_hash ~ '^[a-f0-9]{64}$'),
  invited_by uuid references auth.users(id) on delete set null,
  expires_at timestamptz not null,
  accepted_at timestamptz,
  created_at timestamptz not null default now(),
  check (expires_at > created_at)
);
create index school_invitations_pending_idx on public.school_invitations(school_id, lower(email)) where accepted_at is null;
alter table public.school_invitations enable row level security;
revoke all on public.school_invitations from anon;

create function public.provision_school_with_owner_invite(
  p_name text, p_school_code text, p_owner_email text, p_owner_token_hash text
) returns table (school_id uuid, invitation_id uuid)
language plpgsql security definer set search_path = '' as $$
declare new_school_id uuid; new_invitation_id uuid;
begin
  if not exists (select 1 from public.platform_admins p where p.user_id = (select auth.uid())) then
    raise exception 'Platform administrator access required' using errcode = '42501';
  end if;
  if p_owner_token_hash !~ '^[a-f0-9]{64}$' then raise exception 'Invalid invitation token hash' using errcode = '22023'; end if;
  insert into public.schools(name, school_code) values (trim(p_name), upper(trim(p_school_code))) returning id into new_school_id;
  insert into public.school_invitations(school_id, email, role, token_hash, invited_by, expires_at)
  values (new_school_id, lower(trim(p_owner_email)), 'owner', p_owner_token_hash, (select auth.uid()), now() + interval '7 days')
  returning id into new_invitation_id;
  return query select new_school_id, new_invitation_id;
end;
$$;
revoke all on function public.provision_school_with_owner_invite(text,text,text,text) from public, anon;
grant execute on function public.provision_school_with_owner_invite(text,text,text,text) to authenticated;

create function public.issue_school_invitation(
  p_school_id uuid, p_email text, p_role public.school_role, p_token_hash text
) returns uuid
language plpgsql security definer set search_path = '' as $$
declare new_id uuid;
begin
  if not public.has_school_role(p_school_id, array['owner','admin']::public.school_role[]) then
    raise exception 'School administrator access required' using errcode = '42501';
  end if;
  if p_role not in ('admin','registrar','teacher','viewer') then raise exception 'This role cannot be invited through the standard invitation flow' using errcode = '22023'; end if;
  if p_token_hash !~ '^[a-f0-9]{64}$' then raise exception 'Invalid invitation token hash' using errcode = '22023'; end if;
  insert into public.school_invitations(school_id, email, role, token_hash, invited_by, expires_at)
  values (p_school_id, lower(trim(p_email)), p_role, p_token_hash, (select auth.uid()), now() + interval '7 days')
  returning id into new_id;
  return new_id;
end;
$$;
revoke all on function public.issue_school_invitation(uuid,text,public.school_role,text) from public, anon;
grant execute on function public.issue_school_invitation(uuid,text,public.school_role,text) to authenticated;

create function public.accept_school_invitation(p_raw_token text)
returns table (school_id uuid, granted_role public.school_role)
language plpgsql security definer set search_path = '' as $$
declare invite public.school_invitations%rowtype; account_email text; token_digest text;
begin
  if (select auth.uid()) is null then raise exception 'Authentication required' using errcode = '28000'; end if;
  -- Read verified-email state from auth.users rather than trusting client metadata or JWT user_metadata.
  select lower(u.email) into account_email from auth.users u
  where u.id = (select auth.uid()) and u.email_confirmed_at is not null;
  if account_email is null or account_email = '' then
    raise exception 'A confirmed account email is required' using errcode = '42501';
  end if;
  token_digest := encode(extensions.digest(p_raw_token, 'sha256'), 'hex');
  select i.* into invite from public.school_invitations i where i.token_hash = token_digest for update;
  if not found or invite.accepted_at is not null or invite.expires_at <= now() then
    raise exception 'Invitation is invalid, expired, or already used' using errcode = '22023';
  end if;
  if lower(invite.email) <> account_email then raise exception 'Invitation email does not match signed-in account' using errcode = '42501'; end if;
  insert into public.school_memberships(school_id, user_id, role)
  values (invite.school_id, (select auth.uid()), invite.role) on conflict (school_id, user_id) do nothing;
  if exists (
    select 1 from public.school_memberships m
    where m.school_id = invite.school_id and m.user_id = (select auth.uid()) and m.role <> invite.role
  ) then raise exception 'An existing membership has a different role; contact the school owner' using errcode = '23505'; end if;
  update public.school_invitations set accepted_at = now() where id = invite.id;
  return query select invite.school_id, invite.role;
end;
$$;
revoke all on function public.accept_school_invitation(text) from public, anon;
grant execute on function public.accept_school_invitation(text) to authenticated;

create policy "admins view school invitations" on public.school_invitations
  for select to authenticated using (public.has_school_role(school_id, array['owner','admin']::public.school_role[]));
-- No direct INSERT/UPDATE/DELETE policy. Invitation changes go through guarded functions.
