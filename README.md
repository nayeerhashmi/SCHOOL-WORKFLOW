# SCHOOL-WORKFLOW

A secure, error-resistant school data-entry platform for schools in Jammu and Kashmir and beyond.

## Product goals

- Import existing records from spreadsheets and documents without silently corrupting data.
- Provide validated digital forms for new admissions.
- Isolate each school's records in a multi-tenant SaaS architecture.
- Track sensitive record changes with an auditable history.
- Add conflict-safe offline synchronisation in a later milestone.

## Current milestone

**Milestone 1: Secure foundation**

This repository begins with the specification and acceptance criteria. The first application implementation should include tenant isolation, authenticated memberships, student records, database constraints, audit events, and automated tests before adding OCR or offline writes.

## Planned stack

- Next.js, React, and TypeScript
- Supabase Auth and PostgreSQL
- PostgreSQL Row Level Security (RLS)
- Zod validation at the API boundary, backed by database constraints
- Vitest and Playwright
- IndexedDB and conflict-safe synchronisation in a later milestone

## Non-negotiable integrity rules

1. Every tenant-owned row has a `school_id`.
2. Every read and write must be authorised for the active school on the server and protected at database level.
3. Admission numbers are unique within a school.
4. Client-side validation is for usability only. Server validation and database constraints are authoritative.
5. Record updates use optimistic concurrency. Stale writes must not silently overwrite newer records.
6. Import files are staged, validated, reviewed, and explicitly approved before they affect live records.
7. Blank import cells never implicitly erase existing values.
8. Audit history must not be editable by ordinary application users.
9. No real student data, credentials, service keys, or private documents belong in this repository.
10. No feature is described as zero-error. Reliability claims must be supported by automated tests and recovery drills.

## Documentation

- [System design](docs/SYSTEM_DESIGN.md)
- [Milestone 1 acceptance criteria](docs/MILESTONE_1.md)
- [Security model](docs/SECURITY.md)

## Local development

Implementation prerequisites and commands will be documented as the app scaffold is added. Never commit `.env` files or secrets. Use synthetic test data.

## Status

Planning and repository setup. This is not yet a deployed or security-certified application.
