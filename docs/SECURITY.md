# Security Model

## Threat model

Protect school records and uploaded documents from cross-tenant exposure, unauthorised edits, accidental corruption, replayed operations, malicious uploads, compromised sessions, and accidental loss. Student and guardian data is sensitive and should be minimised.

## Identity and access

- Authenticate with Supabase Auth.
- Derive actor identity from the verified server session.
- Check active membership and role for every operation.
- Never accept client-provided user identity as authority.
- Enforce tenant access with database RLS and composite foreign keys, not only UI checks.
- Recheck permissions for asynchronous import workers and file downloads.
- Keep privileged service credentials server-side only.

## Database isolation

Every tenant-owned table includes `school_id`. Enable RLS before the table is exposed to application users. Policies should require active membership in the specific school. Write policies should independently check both the old row and proposed row context. Composite keys and foreign keys must make cross-school relationships impossible.

Security tests must attempt direct queries and ID substitution, not only navigate the UI.

## File handling

- Store uploads in private storage.
- Enforce maximum upload size and allowlisted formats.
- Inspect file signatures instead of relying on filenames alone.
- Quarantine before parsing and scan for malware when a suitable scanning service is configured.
- Parse spreadsheets/documents in isolated workers with resource limits.
- Treat formulas, macros, embedded links, PDF content, and OCR output as untrusted.
- Do not execute spreadsheet formulas or macros during import.
- Issue short-lived signed URLs only after verifying school and object ownership.
- Hash and retain source provenance according to policy.

## Audit and privacy

Audit protected operations using server-side actor identity and timestamps. Exclude tokens, credentials, and needless personal data from logs. Restrict audit reads to authorised roles, and prevent normal application users from editing or deleting events. Establish retention, export, correction, and deletion policies before production.

Review applicable Indian privacy and children's-data laws and the rules in force at launch with qualified counsel. This document is an engineering plan, not legal advice.

## Offline device controls (before enabling offline writes)

- Store only the minimum records needed for the user's work.
- Treat device and browser storage as potentially exposed.
- Recommend and enforce device screen lock and full-disk encryption.
- Distinguish local queued changes from confirmed server writes.
- Clear local data on logout/revocation where feasible, and explain limits of browser-side deletion.
- Reject sync requests from revoked users.
- Preserve unsynced changes through a controlled export/recovery mechanism without bypassing server authorisation.
- Use operation IDs and expected revisions; never silently apply last-write-wins to sensitive school records.

## Operational safeguards

- Separate development, staging, and production.
- Keep secrets in managed environment settings, never commit them.
- Use dependency alerts and lockfiles.
- Rate-limit authentication and write endpoints.
- Log and restrict support access.
- Test backup restoration and incident response.
