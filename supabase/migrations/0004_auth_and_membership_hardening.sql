-- Restrict membership writes to guarded SECURITY DEFINER invitation functions.
drop policy if exists "admins manage memberships" on public.school_memberships;
revoke insert, update, delete, truncate on public.school_memberships from anon, authenticated;
revoke insert, update, delete, truncate on public.school_invitations from anon, authenticated;

create function public.guard_student_update()
returns trigger language plpgsql set search_path = '' as $$
begin
  if new.school_id is distinct from old.school_id then raise exception 'school_id cannot be changed' using errcode = '42501'; end if;
  if new.created_by is distinct from old.created_by then raise exception 'created_by cannot be changed' using errcode = '42501'; end if;
  if new.id is distinct from old.id or new.created_at is distinct from old.created_at then raise exception 'Student identity fields cannot be changed' using errcode = '42501'; end if;
  return new;
end;
$$;
create trigger students_guard_protected_fields before update on public.students for each row execute function public.guard_student_update();
