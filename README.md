# SCHOOL-WORKFLOW

A school data-entry and migration platform designed to reduce manual errors and make student-record imports reviewable and auditable.

## Current stage

The development branch contains the initial architecture, Supabase schema, security hardening, invite-only onboarding database workflow, validation helpers, and starter offline/import types. It is not yet production-ready and has not been security-certified.

## Start here

- [Local setup](docs/LOCAL_SETUP.md)
- [Invite-only onboarding](docs/INVITE_ONLY_ONBOARDING.md)
- [System design](docs/SYSTEM_DESIGN.md)
- [Security model](docs/SECURITY.md)
- [Milestone 1](docs/MILESTONE_1.md)
- [Reference project review](docs/REUSE_AND_INTEGRATION.md)

## Principles

- Enforce school isolation in PostgreSQL, not just the UI.
- Treat imports as staged proposals that require validation and review before commit.
- Preserve provenance and record protected changes in an audit trail.
- Make offline status explicit; local saves are not server-confirmed saves.
- Use synthetic data during development and test restoration before a real-data pilot.

## Important

Never commit Supabase service-role keys or production credentials. The migrations must be reviewed and tested in a disposable development project before real records are used.
