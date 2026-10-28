# Invite-only onboarding (first release)

## Flow

1. A platform administrator creates a Supabase Auth account for themselves.
2. A database owner adds that account's UUID to `public.platform_admins` using the SQL editor. Never expose platform-admin status as editable user metadata.
3. The platform administrator provisions a school and its first owner invitation through `provision_school_with_owner_invite`.
4. The trusted server generates a cryptographically random token with `createInvitationToken()`, hashes it with `hashInvitationToken()`, and passes only the digest to the database function. The raw token is delivered in an email or copied into a controlled development workflow.
5. The invited owner signs up/signs in with the same email address and redeems the token using `accept_school_invitation`.
6. An owner/admin can invite admins, registrars, teachers, and viewers. Only platform provisioning can create the first owner invitation.

## Important current limitations

- The database workflow and token helpers are in place, but the invitation email sender, admin UI, signup/login pages, and rate limits are not implemented yet.
- Do not send raw tokens through logs or analytics. Store only token digests.
- Supabase Auth email confirmation should be enabled. The redemption function compares the token's email claim to the invitation email; production setup must ensure that claim is verified by the configured auth provider.
- A database owner must manually bootstrap the first platform administrator. Do not add a public self-service route for this table.
- Run the migration in a disposable Supabase project and test expired, reused, wrong-email, unauthenticated, and cross-school invitation attempts before real use.
- Self-service school registration is deliberately deferred until abuse prevention, verification, quotas, and platform-admin recovery are designed.
