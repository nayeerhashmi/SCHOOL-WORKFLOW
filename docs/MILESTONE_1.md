# Milestone 1: Secure Foundation

## Goal

Deliver the smallest reliable foundation for multi-school student data entry before building import or offline features.

## Included

- Project scaffolding and documented environment setup.
- Supabase database migrations.
- School records and school memberships.
- Role model for owner/administrator, office staff, teacher, and auditor, with least-privilege permissions.
- Student creation, search, list, and detail page.
- Server-side validation and database constraints.
- Optimistic concurrency field or revision token.
- Audit events for student creation and update.
- Automated unit, integration, and cross-tenant security tests.
- CI checks for linting, type checking, and tests.
- Synthetic seed data only.

## Not included

- OCR and AI document extraction.
- Bulk Excel migration.
- Attendance, fees, examinations, payroll, and report cards.
- Offline writes or synchronisation.
- Production student data.
- Claims of zero errors or security certification.

## Definition of done

1. Two independent test schools can create and read their own student records.
2. A user from School A cannot read, create, modify, search, or export School B data.
3. Cross-school references are rejected by database constraints.
4. Duplicate admission numbers in the same school are rejected, including simultaneous creation attempts.
5. Invalid dates and missing required fields are rejected on the server.
6. A stale update is rejected instead of silently overwriting newer data.
7. Every protected create/update has an audit event linked to an actor and request.
8. No privileged secret appears in the client bundle or Git history.
9. CI passes on the proposed branch.
10. Setup steps are reproducible from a clean checkout.

## Required tests

- Anonymous request cannot read student records.
- Active member can access only the permitted school.
- Inactive/revoked membership cannot write.
- Cross-tenant ID substitution fails for reads and writes.
- Duplicate admission number fails at the database layer.
- Date validation rejects invalid and future dates.
- Invalid class/school reference fails.
- Stale version update produces a conflict.
- Audit history cannot be changed by ordinary staff.
- User with teacher role cannot administer memberships.
- Search results and error messages do not leak records from other tenants.

## Handoff checklist

- [ ] Migrations are committed.
- [ ] RLS enabled and policies reviewed for every tenant-owned table.
- [ ] Tests use synthetic data.
- [ ] Environment variables are documented without secrets.
- [ ] Staging deployment is tested.
- [ ] Backup and recovery plan is recorded before pilot data is used.
