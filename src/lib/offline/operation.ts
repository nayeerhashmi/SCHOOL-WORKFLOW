/** Minimal sync envelope. Never treat a local save as a server-confirmed save. */
export type SyncOperation<T = unknown> = {
  operationId: string;
  schoolId: string;
  entity: "student" | "guardian" | "enrolment";
  action: "create" | "update";
  entityId: string;
  expectedRevision: number | null;
  payload: T;
  createdAt: string;
  status: "queued" | "syncing" | "synced" | "conflict" | "rejected";
};

export function createOperation<T>(input: Omit<SyncOperation<T>, "operationId" | "createdAt" | "status">): SyncOperation<T> {
  return { ...input, operationId: crypto.randomUUID(), createdAt: new Date().toISOString(), status: "queued" };
}

/** Server must enforce membership, idempotency, and revision checks again. */
export function isRetryableStatus(status: number): boolean {
  return status === 408 || status === 425 || status === 429 || status >= 500;
}
