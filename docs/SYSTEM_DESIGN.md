# System Design

## 1. Scope

Build a multi-tenant SaaS school data-entry platform for schools currently using a mixture of paper records, Excel files, PDFs, and other tools. The initial use case is student admissions and core student records. Later milestones add controlled imports, OCR, and offline-first synchronisation.

This repository starts with the specification. It is not yet an implemented or deployed application.

## 2. Architecture

- **Web client:** Next.js, React, TypeScript, mobile-friendly and installable as a PWA.
- **Authentication:** Supabase Auth.
- **Authoritative data store:** Supabase PostgreSQL.
- **Tenant enforcement:** RLS plus explicit server-side membership checks and composite foreign keys.
- **Input validation:** shared TypeScript/Zod schemas plus PostgreSQL constraints.
- **Documents:** private object storage with ownership checks and short-lived signed URLs only when needed.
- **Testing:** Vitest, Playwright, database integration and adversarial cross-tenant tests.
- **Offline (later milestone):** IndexedDB operation queue and revision-based conflict detection. Offline support is not enabled in Milestone 1.

Never trust a school ID or user ID sent by a client without verifying it against the authenticated session and an active membership.

## 3. Domain model

Every tenant-owned row includes `school_id`. Tenant ownership is reinforced with composite unique keys and foreign keys so a row in one school cannot reference another school's record.

Core entities:

- `schools(id, name, status, created_at)`
- `school_memberships(school_id, user_id, role, status, created_at)`
- `academic_years(id, school_id, name, start_date, end_date, status)`
- `classes(id, school_id, name, sort_order, status)`
- `sections(id, school_id, class_id, name, status)`
- `students(id, school_id, admission_number, full_name, date_of_birth, status, version, created_at, updated_at)`
- `guardians(id, school_id, full_name, phone, relationship_notes)`
- `student_guardians(school_id, student_id, guardian_id, is_primary)`
- `enrolments(id, school_id, student_id, academic_year_id, class_id, section_id, roll_number, status)`
- `documents(id, school_id, student_id, storage_key, document_type, verification_status, source_hash)`
- `import_jobs(id, school_id, created_by, source_hash, status, created_at, approved_by, approved_at)`
- `import_rows(id, school_id, job_id, row_number, source_data, proposed_data, validation_errors, status)`
- `audit_events(id, school_id, actor_id, entity_type, entity_id, action, old_values, new_values, occurred_at, request_id)`
- `sync_operations(school_id, operation_id, device_id, status, result, created_at)` (introduced with offline sync)

Use UUID primary keys. Admission numbers are business identifiers, not primary keys. Unique admission number constraint: `UNIQUE (school_id, admission_number)`. Use `DATE` for calendar dates and `TIMESTAMPTZ` for event timestamps. Monetary values must use integer paise or an exact decimal type, never floating point.

## 4. Validation

Validation runs at three levels:
1. Client-side feedback for usability.
2. Server-side validation for all business rules.
3. Database constraints for invariants that must always hold.

Initial hard rules:
- Full name and admission number are required on final submission.
- Date of birth must be a valid date, cannot be in the future, and any age-related rule is configured explicitly rather than assumed.
- Admission number is unique within a school and normalised only according to documented school settings.
- All student, guardian, class, section, and academic-year relationships must be within the same school.
- Class and section references must exist and be active.
- Update requests include an expected record version. Stale writes fail with a conflict rather than overwriting current data.
- Names preserve original spelling, punctuation, spaces, and regional conventions. Do not auto-correct names.
- Empty fields in an import do not erase non-empty fields unless the user explicitly selects and confirms a clear operation.

## 5. Import pipeline (later milestone)

1. Upload into private quarantine storage; enforce size and file-type checks.
2. Calculate a cryptographic hash and retain source provenance.
3. Parse XLSX/CSV/PDF/image content in an isolated background process.
4. Map source columns to schema fields and show a preview.
5. Stage rows separately from live tables.
6. Validate field formats, uniqueness, relationships, and possible duplicate identities.
7. Show row-level errors and uncertain OCR fields with source references.
8. Require an authorised human to approve changes.
9. Commit approved rows transactionally or in an explicitly reconciled idempotent batch.
10. Produce a reconciliation report: created, updated, skipped, rejected, and unresolved records.

Never merge solely on names. Never apply OCR output automatically when identity or field confidence is uncertain. Keep a reference to the original page/image region for review where feasible.

## 6. Offline sync (later milestone)

Each local operation includes a UUID operation ID, target record ID, expected server version, allowed field changes, schema version, and local creation timestamp for diagnostics. The server determines the acting user from the verified session and validates current school membership.

Process each operation transactionally:
- Check idempotency key.
- Verify session, membership, permissions, and tenant ownership.
- Validate the operation against the current record.
- Compare expected and actual server versions.
- Apply only on a matching version and increment the version.
- Otherwise retain the local change as a visible conflict.

Never use last-write-wins for student identity, admission number, date of birth, or other sensitive fields. Distinguish local-only saved state from server-synced state. Offline device revocation, limited offline datasets, local data clearing, and secure recovery are mandatory design considerations before enabling offline use.

## 7. Audit

Audit events cover student creation and edits, import uploads and approvals, exports, role and membership changes, archival, privileged access, and conflict resolution. Use server-generated event timestamps and actor IDs. Restrict update/delete rights on audit records. Do not log passwords, tokens, or unnecessary personal data.

For initial implementation, record changed field names and safe before/after values where necessary, avoiding excessive copies of sensitive student information. Define retention and redaction rules before production.

## 8. Security

- RLS enabled on every tenant-owned table before use.
- Policies require an active membership for the row's school.
- Composite foreign keys prevent cross-school references.
- No Supabase service-role key in client code.
- Private storage; validate tenant ownership before access.
- Least-privilege roles and server-side permission checks.
- Secrets only in environment variables provided by the deployment platform; no committed secrets.
- Rate limiting and appropriate CSRF/session protections for write paths.
- Synthetic data for tests and development.
- Logged and restricted platform support access.
- Separate development, staging, and production projects.

## 9. Backups and recovery

Initial goals (to be confirmed against hosting plan): RPO <= 24 hours; RTO <= 8 hours. Use encrypted automated database backups and separate protected copies of documents. A database backup alone is insufficient. Perform a restore drill at least quarterly during the pilot. Verify record counts, foreign keys, file hashes, tenant isolation, and application workflows before returning to service.

Offline operations created after a recovery point must be replayed idempotently and checked for conflicts, never blindly re-applied.

## 10. Rollout

1. Secure foundation and student records.
2. Controlled spreadsheet migration and reconciliation.
3. OCR and source-based verification.
4. Offline operation queue and conflict handling.
5. Pilot with synthetic/test data, then a controlled school migration after approval.

Do not enable real student records until the tenant isolation, migration, audit, access control, and recovery tests pass.
