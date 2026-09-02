import { createHash } from "node:crypto";

export interface ExecutionAuthorization {
  version: 1;
  kind: "EXECUTION_AUTH";
  proposalId: string;       // 32-byte hex
  sourceChain: bigint;
  destinationChain: bigint;
  sourceEndpoint: string;   // 32-byte hex
  executor: string;         // 28-byte Cardano payment credential hex
  actionKind: "TREASURY_PAYMENT";
  recipient: string;        // 28-byte Cardano payment credential hex
  amount: bigint;
  nonce: bigint;
  notBefore: bigint;
  expiresAt: bigint;
}

function u64(n: bigint): Buffer {
  const b = Buffer.alloc(8); b.writeBigUInt64BE(n); return b;
}
function bytes(hex: string, size?: number): Buffer {
  const b = Buffer.from(hex.replace(/^0x/, ""), "hex");
  if (size !== undefined && b.length !== size) throw new Error(`Expected ${size} bytes, got ${b.length}`);
  return b;
}

/** Stable, length-delimited wire representation for hashing/signing. */
export function encodeExecutionAuthorization(a: Omit<ExecutionAuthorization, "version" | "kind">): Buffer {
  const kind = Buffer.from("TREASURY_PAYMENT", "ascii");
  return Buffer.concat([
    Buffer.from([1]),
    u64(a.sourceChain), u64(a.destinationChain),
    bytes(a.proposalId, 32), bytes(a.sourceEndpoint, 32), bytes(a.executor, 28),
    Buffer.from([kind.length]), kind,
    bytes(a.recipient, 28), u64(a.amount), u64(a.nonce), u64(a.notBefore), u64(a.expiresAt),
  ]);
}

export function computeActionHash(a: Omit<ExecutionAuthorization, "version" | "kind">): string {
  return createHash("sha256").update(encodeExecutionAuthorization(a)).digest("hex");
}

export function buildExecutionAuth(input: Omit<ExecutionAuthorization, "version" | "kind">): ExecutionAuthorization {
  return { ...input, version: 1, kind: "EXECUTION_AUTH" };
}
