# VIA custom integration package

## Target networks

- Cardano Preprod VIA chain ID: `2273266`
- Midnight Preview VIA chain ID: `64364450`

VIA documents these networks and says custom Cardano `chain_data` / validator logic requires a matching executor in VIA's off-chain driver. Custom integrations are built together with VIA.

## Application protocol

### 1. CARDANO_VOTE

Cardano voting adapter -> VIA -> Midnight `processCardanoVote`.

Required fields:
- `messageId`
- `sourceChain`
- `sourceEndpoint`
- `proposalId`
- `voteNullifier`
- `support`
- `votingPower`
- `snapshot`

### 2. EXECUTION_AUTH

Midnight `finalizeProposal` -> VIA -> Cardano DAO executor.

The message commits to:
- proposal ID
- nonce
- action kind (`TREASURY_PAYMENT`)
- recipient
- amount
- not-before / expiry
- executor identity
- action hash

### 3. EXECUTION_RESULT

Cardano executor -> VIA -> Midnight `processExecutionResult`.

The result includes the Cardano transaction ID and the exact action hash that was executed.

## VIA onboarding deliverables

Provide VIA with:
1. Cardano Preprod validator scripts and hashes.
2. Cardano voting-adapter endpoint identity.
3. Cardano executor endpoint identity.
4. Midnight Preview PrivateDAO deployment identity.
5. The three frozen payload schemas.
6. Route direction and confirmation requirements.
7. The Cardano custom executor/off-chain-driver requirements.
8. Test cases and expected payloads.

## Endpoint allowlists

Midnight must allow the Cardano voting endpoint. Cardano must accept only the configured Midnight PrivateDAO executor endpoint. Exact endpoint values are supplied by the deployed contracts and VIA integration; do not invent them.

## Critical boundary

Do not implement or guess VIA's proprietary validator/relayer internals. The repository contains the application protocol and the on-chain application boundary. VIA supplies/wires the message-layer integration and custom off-chain driver support during onboarding.

Never send seed phrases, signing keys, wallet JSON, API tokens, or VIA credentials to VIA or commit them to this repository.
