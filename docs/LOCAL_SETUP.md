# Local setup

Requirements: Node.js 20 or newer, npm, and a separate development Supabase project.

1. Clone the repository and check out `milestone-1-secure-foundation`.
2. Run `npm install`.
3. Copy `.env.example` to `.env.local` and enter the development Supabase project URL and publishable/anon key.
4. Apply migrations 0001 through 0004 in order to the development project, or link the Supabase CLI to the correct project and run `supabase db push`.
5. Configure email confirmation, allowed redirect URLs, and SMTP. See [Authentication](AUTHENTICATION.md) and [Invite-only onboarding](INVITE_ONLY_ONBOARDING.md).
6. Run `npm run typecheck`, `npm test`, `npm run lint`, and `npm run build`.
7. Run `npm run dev`.

Do not use real student records until migrations, RLS, provisioning, server-side writes, audit behaviour, and cross-tenant tests have been verified.
