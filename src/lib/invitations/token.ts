import { createHash, randomBytes } from "node:crypto";

/** Generate a one-time bearer token. Send the raw token only to the invited user. */
export function createInvitationToken(): string {
  return randomBytes(32).toString("hex");
}

/** Store this digest in PostgreSQL, never the raw invitation token. */
export function hashInvitationToken(rawToken: string): string {
  return createHash("sha256").update(rawToken, "utf8").digest("hex");
}
