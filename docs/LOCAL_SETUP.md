# Local setup

## Requirements

- Node.js 20 or newer
- npm
- A separate development Supabase project (do not use production data)

## Steps

1. Clone the repository and check out `milestone-1-secure-foundation`.
2. Run `npm install`.
3. Copy `.env.example` to `.env.local` and fill in the development project's project URL and publishable/anon key.
4. Apply migrations in order in the development project, or use the Supabase CLI after linking the correct project: `supabase db push`.
5. Run `npm run typecheck` and `npm test`.
6. Run `npm run dev` to start the local Next.js server.

Do not use real student records until RLS, provisioning, server-side writes, audit behaviour, and cross-tenant tests have been verified. The current stage does not yet include a complete login UI or school provisioning workflow.
