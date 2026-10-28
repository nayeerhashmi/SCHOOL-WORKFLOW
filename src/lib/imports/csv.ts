import { studentInputSchema, normalizeAdmissionNumber, type StudentInput } from "@/lib/validation/student";

export type CsvRowResult = { rowNumber: number; data?: StudentInput; errors: string[] };

/**
 * Parse a CSV that has already been decoded as UTF-8 text.
 * This deliberately rejects quoted fields/newlines for now rather than silently
 * corrupting values. Replace with a vetted CSV parser before general release.
 */
export function validateSimpleCsv(text: string): CsvRowResult[] {
  const lines = text.replace(/^\\uFEFF/, "").split(/\\r?\\n/).filter((line) => line.trim().length > 0);
  if (lines.length < 2) return [];
  if (lines.some((line) => line.includes('"'))) {
    throw new Error("Quoted CSV fields are not supported by this starter parser. Use a full CSV parser before importing this file.");
  }
  const headers = lines[0].split(",").map((v) => v.trim().toLowerCase());
  const required = ["admissionnumber", "firstname", "lastname"];
  const missing = required.filter((h) => !headers.includes(h));
  if (missing.length) throw new Error(`Missing required columns: ${missing.join(", ")}`);
  const seen = new Set<string>();
  return lines.slice(1).map((line, index) => {
    const values = line.split(",");
    const raw: Record<string, string> = {};
    headers.forEach((header, i) => { raw[header] = (values[i] ?? "").trim(); });
    const parsed = studentInputSchema.safeParse({
      admissionNumber: raw.admissionnumber,
      firstName: raw.firstname,
      middleName: raw.middlename ?? "",
      lastName: raw.lastname,
      dateOfBirth: raw.dateofbirth ?? "",
      gender: raw.gender || "not_recorded",
    });
    const errors: string[] = [];
    if (!parsed.success) errors.push(...parsed.error.issues.map((issue) => `${issue.path.join(".")}: ${issue.message}`));
    if (parsed.success) {
      const key = normalizeAdmissionNumber(parsed.data.admissionNumber);
      if (seen.has(key)) errors.push("Duplicate admission number within this file");
      seen.add(key);
      return { rowNumber: index + 2, data: parsed.data, errors };
    }
    return { rowNumber: index + 2, errors };
  });
}
