-- Security hardening for the initial schema. Apply after 0001 in a disposable project first.

-- A section must belong to the same class as its enrolment.
alter table public.sections add constraint sections_school_class_id_unique unique (school_id, class_id, id);
alter table public.enrolments drop constraint enrolments_school_id_section_id_fkey;
alter table public.enrolments add constraint enrolments_school_class_section_fk
  foreign key (school_id, class_id, section_id)
  references public.sections(school_id, class_id, id) on delete restrict;

-- Tenant ownership is immutable after creation. Moving a record between schools
-- must be a separately designed, audited administrative workflow.
create function public.prevent_school_id_change()
returns trigger language plpgsql set search_path = '' as $$
begin
  if new.school_id is distinct from old.school_id then
    raise exception 'school_id cannot be changed';
  end if;
  return new;
end;
$$;

create trigger students_school_id_immutable before update on public.students
for each row execute function public.prevent_school_id_change();
create trigger enrolments_school_id_immutable before update on public.enrolments
for each row execute function public.prevent_school_id_change();
create trigger academic_years_school_id_immutable before update on public.academic_years
for each row execute function public.prevent_school_id_change();
create trigger classes_school_id_immutable before update on public.classes
for each row execute function public.prevent_school_id_change();
create trigger sections_school_id_immutable before update on public.sections
for each row execute function public.prevent_school_id_change();

-- Keep revision and updated_at server-managed. Clients must submit the expected
-- revision in the WHERE clause for optimistic concurrency control.
create function public.bump_student_revision()
returns trigger language plpgsql set search_path = '' as $$
begin
  new.revision := old.revision + 1;
  new.updated_at := now();
  return new;
end;
$$;
create trigger students_bump_revision before update on public.students
for each row execute function public.bump_student_revision();

-- Audit records are inserted by a SECURITY DEFINER trigger, not by client input.
create function public.write_student_audit_event()
returns trigger language plpgsql security definer set search_path = '' as $$
declare
  event_action text;
  event_entity uuid;
  event_school uuid;
  event_details jsonb;
begin
  if tg_op = 'INSERT' then
    event_action := 'student.created'; event_entity := new.id; event_school := new.school_id;
    event_details := jsonb_build_object('admission_number', new.admission_number, 'revision', new.revision);
  elsif tg_op = 'UPDATE' then
    event_action := 'student.updated'; event_entity := new.id; event_school := new.school_id;
    event_details := jsonb_build_object('revision_before', old.revision, 'revision_after', new.revision);
  else
    event_action := 'student.deleted'; event_entity := old.id; event_school := old.school_id;
    event_details := jsonb_build_object('admission_number', old.admission_number);
  end if;
  insert into public.audit_events(school_id, actor_id, action, entity_type, entity_id, details)
  values (event_school, auth.uid(), event_action, 'student', event_entity, event_details);
  return case when tg_op = 'DELETE' then old else new end;
end;
$$;
revoke all on function public.write_student_audit_event() from public, anon, authenticated;
create trigger students_write_audit after insert or update or delete on public.students
for each row execute function public.write_student_audit_event();

-- Audit events must not be changed by any client role. RLS already has read-only
-- access for authorised admins and deliberately has no insert/update/delete policy.
revoke insert, update, delete, truncate, references, trigger on public.audit_events from anon, authenticated;

-- Explicitly prevent unauthenticated access to every tenant-owned table.
revoke all on public.schools, public.school_memberships, public.academic_years,
  public.classes, public.sections, public.students, public.enrolments, public.audit_events from anon;
