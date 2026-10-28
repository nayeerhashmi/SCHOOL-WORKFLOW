# School setup

The screen at `/school-setup` lets school owners and administrators create academic years, classes, and sections. Each section is attached to a class. Server-side Zod validation checks input and dates, and writes use the authenticated Supabase client under existing row-level security policies. Database uniqueness constraints prevent duplicate academic year names, class names, and section names within a class.

Accounts with administrator access to multiple schools are blocked until explicit workspace switching is implemented. Edit/delete controls are intentionally omitted to avoid breaking existing enrolments. This workflow has not yet been exercised against a live Supabase database; test it with synthetic data before production use.
