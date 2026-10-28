# Student registration

The first registration screen is at `/students/new`. Admission number, full name, academic year, and class are required. Date of birth, gender, section, guardian name, phone, and address are optional. Documents can be attached after saving the record.

Apply migration 0005 after migrations 0001–0004. It adds student fields, case-insensitive admission uniqueness, a transactional registration RPC, document metadata, and a private `student-documents` Storage bucket.

The school ID is derived from the authenticated user's membership and rechecked in the database RPC. Accounts with multiple registrar/admin/owner memberships are blocked until explicit workspace switching exists. The RPC validates academic year, class and section ownership and creates the student plus enrolment atomically. A unique index protects against concurrent duplicate admission numbers. Document uploads are separate, private, restricted to PDF/JPEG/PNG/WebP up to 10 MB, and Storage policies check the school/student path and staff role.

This code has not been run against a real Supabase project. Test RLS, cross-school IDs, duplicate case variants and concurrent duplicate attempts, storage policies, and invitation flows before using real student records.
