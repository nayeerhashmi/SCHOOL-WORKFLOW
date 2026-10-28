import { z } from "zod";

// Validate at the boundary; PostgreSQL constraints remain the final authority.
export const studentInputSchema = z.object({
  admissionNumber: z.string().trim().min(1).max(40),
  firstName: z.string().trim().min(1).max(100),
  middleName: z.string().trim().max(100).optional().default(""),
  lastName: z.string().trim().min(1).max(100),
  dateOfBirth: z.iso.date().optional().or(z.literal("")),
  gender: z.enum(["female", "male", "other", "not_recorded"]).default("not_recorded"),
});

export type StudentInput = z.infer<typeof studentInputSchema>;

export function normalizeAdmissionNumber(value: string): string {
  return value.trim().normalize("NFKC").toLocaleUpperCase("en-IN");
}
