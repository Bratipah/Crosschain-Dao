import { createHash } from "node:crypto";

export const CARDANO_PREPROD_VIA_CHAIN_ID = 2_273_266n;
export const MIDNIGHT_PREVIEW_VIA_CHAIN_ID = 64_364_450n;
export type Support = 1 | 2 | 3;

export interface CardanoVoteMessage {
  version: 1;
  kind: "CARDANO_VOTE";
  sourceChain: bigint;
  sourceEndpoint: string; // 32-byte hex
  proposalId: string;     // 32-byte hex
  voteNullifier: string;  // 32-byte hex
  support: Support;
  votingPower: bigint;
  snapshot: bigint;
  messageId: string;      // 32-byte digest
}

function u64(n: bigint): Buffer { const b = Buffer.alloc(8); b.writeBigUInt64BE(n); return b; }
function bytes(hex: string, size: number): Buffer { const b = Buffer.from(hex, "hex"); if (b.length !== size) throw new Error(`Expected ${size} bytes`); return b; }

export function encodeCardanoVote(m: Omit<CardanoVoteMessage, "messageId">): Buffer {
  return Buffer.concat([
    Buffer.from([1, 1]),
    u64(m.sourceChain), bytes(m.sourceEndpoint, 32), bytes(m.proposalId, 32),
    bytes(m.voteNullifier, 32), Buffer.from([m.support]), u64(m.votingPower), u64(m.snapshot),
  ]);
}

export function buildCardanoVote(input: Omit<CardanoVoteMessage, "messageId" | "version" | "kind">): CardanoVoteMessage {
  const base = { ...input, version: 1 as const, kind: "CARDANO_VOTE" as const };
  const messageId = createHash("sha256").update(encodeCardanoVote(base)).digest("hex");
  return { ...base, messageId };
}
