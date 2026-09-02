import { buildCardanoVote } from "../via/messages/cardano-vote.js";
import { buildExecutionAuth } from "../via/messages/execution-auth.js";
import { buildExecutionResult } from "../via/messages/execution-result.js";

const proposalId = "00".repeat(31) + "01";
const sourceEndpoint = "11".repeat(32);
const cardanoCredential = "22".repeat(28);
const midnightEndpoint = "33".repeat(32);
const actionTxId = "44".repeat(32);

const vote = buildCardanoVote({
  sourceChain: 2_273_266n,
  sourceEndpoint,
  proposalId,
  voteNullifier: "55".repeat(32),
  support: 1,
  votingPower: 100n,
  snapshot: 1n,
});

const auth = buildExecutionAuth({
  proposalId,
  sourceChain: 64_364_450n,
  destinationChain: 2_273_266n,
  sourceEndpoint: midnightEndpoint,
  executor: cardanoCredential,
  actionKind: "TREASURY_PAYMENT",
  recipient: cardanoCredential,
  amount: 1_000_000n,
  nonce: 1n,
  notBefore: 0n,
  expiresAt: 9_999_999_999n,
});

const result = buildExecutionResult({
  sourceChain: 2_273_266n,
  sourceExecutor: cardanoCredential,
  proposalId,
  nonce: auth.nonce,
  success: true,
  actionHash: auth.actionHash,
  cardanoTxId: actionTxId,
});

console.log(JSON.stringify({ CARDANO_VOTE: vote, EXECUTION_AUTH: auth, EXECUTION_RESULT: result }, (_k, v) => typeof v === "bigint" ? v.toString() : v, 2));
