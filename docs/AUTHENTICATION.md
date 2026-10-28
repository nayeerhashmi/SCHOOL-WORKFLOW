# Authentication flow

The first release uses Supabase Auth email/password, email confirmation, and password reset.

- `/login`: sign in with email and password; safe local `next` redirects preserve an invitation link through sign-in.
- `/forgot-password`: request a reset email. The response is intentionally generic to reduce account enumeration.
- `/auth/reset-password`: update the password after opening a valid recovery link.
- `/auth/callback`: exchange Supabase's one-time auth code and allow only local relative redirect paths.
- `/accept-invite`: create an account or redeem a school invitation. An invitation token is required before account creation.
- `/dashboard`: server-side session check and list of school memberships.

## Supabase dashboard configuration

1. Set the site URL to your development URL.
2. Add the local callback and password-reset URLs to the allowed redirect URLs, such as `http://localhost:3000/auth/callback` and `http://localhost:3000/auth/reset-password`.
3. Enable email confirmation.
4. Configure SMTP before inviting real users. Default provider limits may make production invitation emails unreliable.
5. Apply migrations 0001 through 0004 to a disposable development project.
6. Test sign-up confirmation, sign-in, expired reset links, wrong-email invitation redemption, reused invitation tokens, and school isolation.

The repository CI workflow runs type checking, unit tests, lint, and a production build. It has not yet been observed passing, and no live Supabase project has been configured.
