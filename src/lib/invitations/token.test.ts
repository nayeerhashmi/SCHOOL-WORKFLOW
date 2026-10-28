import { describe, expect, it } from "vitest";
import { createInvitationToken, hashInvitationToken } from "./token";

describe("invitation tokens", () => {
  it("generates a high-entropy 64-character hex token", () => {
    const token = createInvitationToken();
    expect(token).toMatch(/^[a-f0-9]{64}$/);
  });
  it("stores a deterministic SHA-256 digest rather than the raw token", () => {
    const token = createInvitationToken();
    expect(hashInvitationToken(token)).toMatch(/^[a-f0-9]{64}$/);
    expect(hashInvitationToken(token)).toBe(hashInvitationToken(token));
    expect(hashInvitationToken(token)).not.toBe(token);
  });
});
