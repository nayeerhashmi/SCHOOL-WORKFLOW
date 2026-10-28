# Reuse and integration notes

Reviewed repositories:

- [Focus](https://github.com/davicanada/Focus): useful product/architecture reference for Next.js, Supabase RLS, role-based school dashboards, student/class CRUD, and spreadsheet import/export. Its repository declares proprietary rights reserved and has no reuse license visible, so no source code was copied.
- [smart-school-os](https://github.com/Wajid16/smart-school-os): useful design reference for offline queues, school-scoped records, idempotent operation IDs, and clear offline/sync states. No license file was found in the reviewed tree, so its source code and assets were not copied.
- [school-management-system](https://github.com/Qnx-EmergingTech/school-management-system): useful conceptual reference for PWA offline storage, conflict handling, sync visibility, and accessibility. Its large implementation claims have not been independently verified.

Implemented here as original starter code:

- A Next.js/TypeScript project manifest.
- A first Supabase migration with school memberships, roles, academic years, classes, sections, students, enrolments, tenant-aware composite foreign keys, unique admission numbers per school, and RLS policies.
- Zod validation and admission-number normalization.
- A sync-operation envelope designed for idempotency, optimistic concurrency, and explicit conflict states.
- A deliberately limited CSV validation helper that rejects quoted CSV instead of silently misparsing it.

Not yet implemented: UI pages, login flow, school provisioning, audited server-side writes, actual IndexedDB persistence, sync API, spreadsheet/XLSX parsing, PDF/OCR ingestion, staged import/approval/commit workflow, backups, and automated tests. Do not use real student data until the migration has been reviewed and security tests pass.
