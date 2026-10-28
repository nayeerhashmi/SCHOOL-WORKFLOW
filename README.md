# SCHOOL-WORKFLOW

A school data-entry and migration platform designed to reduce manual errors and make student-record imports reviewable and auditable.

## Current stage

The development branch includes the initial database foundation, invite-only onboarding, email/password authentication screens, password recovery, a first dashboard, and the first student registration workflow with school-scoped access checks, duplicate admission protection, and private document storage. It is not production-ready and has not been security-certified. No live Supabase project has been configured.

## Start here

- [Local setup](docs/LOCAL_SETUP.md)
- [Authentication](docs/AUTHENTICATION.md)
- [Invite-only onboarding](docs/INVITE_ONLY_ONBOARDING.md)
- [Student registration](docs/STUDENT_REGISTRATION.md)
- [System design](docs/SYSTEM_DESIGN.md)
- [Security model](docs/SECURITY.md)
- [Milestone 1](docs/MILESTONE_1.md)
- [Reference project review](docs/REUSE_AND_INTEGRATION.md)

Never commit service-role keys or production credentials. Test migrations using synthetic data before using real records.
