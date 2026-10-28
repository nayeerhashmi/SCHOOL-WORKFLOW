import { describe, expect, it } from "vitest";
import { normalizeAdmissionNumber, studentInputSchema } from "./student";

describe("studentInputSchema", () => {
  it("accepts valid minimum student data", () => {
    expect(studentInputSchema.safeParse({ admissionNumber: " A-001 ", firstName: "Asha", lastName: "Kumar" }).success).toBe(true);
  });
  it("rejects missing admission number", () => {
    expect(studentInputSchema.safeParse({ admissionNumber: "", firstName: "Asha", lastName: "Kumar" }).success).toBe(false);
  });
  it("rejects malformed dates", () => {
    expect(studentInputSchema.safeParse({ admissionNumber: "A-001", firstName: "Asha", lastName: "Kumar", dateOfBirth: "31-02-2015" }).success).toBe(false);
  });
  it("normalizes admission number for duplicate checks", () => {
    expect(normalizeAdmissionNumber("  ab-01 ")).toBe("AB-01");
  });
});
