import { createHash } from "node:crypto";

export interface ExecutionResultMessage {
  version: 1;
  kind: "EXECUTION_RESULT";
  sourceChain: bigint;
  sourceExecutor: string; // 28-byte Cardano credential
  proposalId: string;     // 32-byte hex
  nonce: bigint;
  success: boolean;
  actionHash: string;     // 32-byte hex
  cardanoTxId: string;    // 32-byte tx id
  messageId: string;
}

function u64(n: bigint): Buffer { const b = Buffer.alloc(8); b.writeBigUInt64BE(n); return b; }
function bytes(hex: string, size: number): Buffer { const b = Buffer.from(hex, "hex"); if (b.length !== size) throw new Error(`Expected ${size} bytes`); return b; }

export function encodeExecutionResult(m: Omit<ExecutionResultMessage, "messageId">): Buffer {
  return Buffer.concat([
    Buffer.from([1, 3]), u64(m.sourceChain), bytes(m.sourceExecutor, 28), bytes(m.proposalId, 32),
    u64(m.nonce), Buffer.from([m.success ? 1 : 0]), bytes(m.actionHash, 32), bytes(m.cardanoTxId, 32),
  ]);
}

export function buildExecutionResult(input: Omit<ExecutionResultMessage, "messageId" | "version" | "kind">): ExecutionResultMessage {
  const base = { ...input, version: 1 as const, kind: "EXECUTION_RESULT" as const };
  const messageId = createHash("sha256").update(encodeExecutionResult(base)).digest("hex");
  return { ...base, messageId };
}
