-- School Workflow foundation. Review and apply in a disposable Supabase project first.
create extension if not exists pgcrypto;

create type public.school_role as enum ('owner', 'admin', 'registrar', 'teacher', 'viewer');
create type public.student_status as enum ('active', 'inactive', 'transferred', 'withdrawn');

create table public.schools (
  id uuid primary key default gen_random_uuid(),
  name text not null check (length(trim(name)) between 2 and 180),
  school_code text not null unique check (school_code ~ '^[A-Z0-9-]{2,20}$'),
  created_at timestamptz not null default now()
);

create table public.school_memberships (
  school_id uuid not null references public.schools(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role public.school_role not null default 'viewer',
  created_at timestamptz not null default now(),
  primary key (school_id, user_id)
);

create table public.academic_years (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools(id) on delete cascade,
  name text not null check (length(trim(name)) between 4 and 30),
  starts_on date not null,
  ends_on date not null,
  created_at timestamptz not null default now(),
  unique (school_id, id),
  unique (school_id, name),
  check (ends_on > starts_on)
);

create table public.classes (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools(id) on delete cascade,
  name text not null check (length(trim(name)) between 1 and 80),
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  unique (school_id, id),
  unique (school_id, name)
);

create table public.sections (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools(id) on delete cascade,
  class_id uuid not null,
  name text not null check (length(trim(name)) between 1 and 40),
  created_at timestamptz not null default now(),
  unique (school_id, id),
  unique (school_id, class_id, name),
  foreign key (school_id, class_id) references public.classes(school_id, id) on delete restrict
);

create table public.students (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools(id) on delete cascade,
  admission_number text not null check (length(trim(admission_number)) between 1 and 40),
  first_name text not null check (length(trim(first_name)) between 1 and 100),
  middle_name text not null default '' check (length(middle_name) <= 100),
  last_name text not null check (length(trim(last_name)) between 1 and 100),
  date_of_birth date,
  gender text not null default 'not_recorded' check (gender in ('female','male','other','not_recorded')),
  status public.student_status not null default 'active',
  revision integer not null default 1 check (revision > 0),
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (school_id, id),
  unique (school_id, admission_number)
);

create table public.enrolments (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools(id) on delete cascade,
  student_id uuid not null,
  academic_year_id uuid not null,
  class_id uuid not null,
  section_id uuid,
  created_at timestamptz not null default now(),
  unique (school_id, id),
  unique (school_id, student_id, academic_year_id),
  foreign key (school_id, student_id) references public.students(school_id, id) on delete restrict,
  foreign key (school_id, academic_year_id) references public.academic_years(school_id, id) on delete restrict,
  foreign key (school_id, class_id) references public.classes(school_id, id) on delete restrict,
  foreign key (school_id, section_id) references public.sections(school_id, id) on delete restrict
);

create table public.audit_events (
  id bigint generated always as identity primary key,
  school_id uuid not null references public.schools(id) on delete cascade,
  actor_id uuid references auth.users(id) on delete set null,
  action text not null check (length(action) between 1 and 80),
  entity_type text not null check (length(entity_type) between 1 and 80),
  entity_id uuid,
  request_id uuid,
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index students_school_name_idx on public.students(school_id, last_name, first_name);
create index enrolments_school_year_idx on public.enrolments(school_id, academic_year_id);
create index audit_events_school_created_idx on public.audit_events(school_id, created_at desc);

create function public.is_school_member(target_school uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.school_memberships m
    where m.school_id = target_school and m.user_id = (select auth.uid())
  );
$$;
revoke all on function public.is_school_member(uuid) from public;
grant execute on function public.is_school_member(uuid) to authenticated;

create function public.has_school_role(target_school uuid, allowed public.school_role[])
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.school_memberships m
    where m.school_id = target_school and m.user_id = (select auth.uid()) and m.role = any(allowed)
  );
$$;
revoke all on function public.has_school_role(uuid, public.school_role[]) from public;
grant execute on function public.has_school_role(uuid, public.school_role[]) to authenticated;

alter table public.schools enable row level security;
alter table public.school_memberships enable row level security;
alter table public.academic_years enable row level security;
alter table public.classes enable row level security;
alter table public.sections enable row level security;
alter table public.students enable row level security;
alter table public.enrolments enable row level security;
alter table public.audit_events enable row level security;

create policy "members can view their schools" on public.schools for select to authenticated using (public.is_school_member(id));
create policy "members can view memberships in their schools" on public.school_memberships for select to authenticated using (public.is_school_member(school_id));
create policy "admins manage memberships" on public.school_memberships for all to authenticated using (public.has_school_role(school_id, array['owner','admin']::public.school_role[])) with check (public.has_school_role(school_id, array['owner','admin']::public.school_role[]));
create policy "members read academic years" on public.academic_years for select to authenticated using (public.is_school_member(school_id));
create policy "admins manage academic years" on public.academic_years for all to authenticated using (public.has_school_role(school_id, array['owner','admin']::public.school_role[])) with check (public.has_school_role(school_id, array['owner','admin']::public.school_role[]));
create policy "members read classes" on public.classes for select to authenticated using (public.is_school_member(school_id));
create policy "admins manage classes" on public.classes for all to authenticated using (public.has_school_role(school_id, array['owner','admin']::public.school_role[])) with check (public.has_school_role(school_id, array['owner','admin']::public.school_role[]));
create policy "members read sections" on public.sections for select to authenticated using (public.is_school_member(school_id));
create policy "admins manage sections" on public.sections for all to authenticated using (public.has_school_role(school_id, array['owner','admin']::public.school_role[])) with check (public.has_school_role(school_id, array['owner','admin']::public.school_role[]));
create policy "members read students" on public.students for select to authenticated using (public.is_school_member(school_id));
create policy "authorized staff create students" on public.students for insert to authenticated with check (public.has_school_role(school_id, array['owner','admin','registrar']::public.school_role[]) and created_by = (select auth.uid()));
create policy "authorized staff update students" on public.students for update to authenticated using (public.has_school_role(school_id, array['owner','admin','registrar']::public.school_role[])) with check (public.has_school_role(school_id, array['owner','admin','registrar']::public.school_role[]));
create policy "admins delete students" on public.students for delete to authenticated using (public.has_school_role(school_id, array['owner','admin']::public.school_role[]));
create policy "members read enrolments" on public.enrolments for select to authenticated using (public.is_school_member(school_id));
create policy "registrars manage enrolments" on public.enrolments for all to authenticated using (public.has_school_role(school_id, array['owner','admin','registrar']::public.school_role[])) with check (public.has_school_role(school_id, array['owner','admin','registrar']::public.school_role[]));
create policy "members read audit events" on public.audit_events for select to authenticated using (public.has_school_role(school_id, array['owner','admin']::public.school_role[]));

-- Intentionally no client write policy for audit_events. Write through a trusted server function.
-- Do not expose service-role credentials in browser code. Test RLS in Supabase before real student data.
