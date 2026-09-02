# Cardano ↔ Midnight Omnichain DAO — Treasury Payment Testnet

This repository implements a concrete two-way governance flow:

```text
Cardano voter
   │
   ▼
Voting Adapter
   │ CARDANO_VOTE
   ▼
VIA
   │
   ▼
Midnight PrivateDAO
   │ private voting / quorum / threshold
   │
   ▼
FINALIZE
   │
   │ EXECUTION_AUTH
   ▼
VIA
   │
   ▼
Cardano DAO Executor
   │
   ▼
Treasury UTxO
   │ TREASURY_PAYMENT
   ▼
Recipient
   │
   │ EXECUTION_RESULT
   ▼
VIA → Midnight
```

## Scope

V1 intentionally supports one concrete Cardano action: `TREASURY_PAYMENT`.

Midnight commits the exact:

- proposal ID
- execution nonce
- recipient
- amount
- timelock
- expiry
- executor identity
- action hash

Cardano executes only that committed action. There is no arbitrary EVM-style target/calldata executor.

## Testnet

The intended VIA testnet pair is:

- Cardano Preprod: VIA chain ID `2273266`
- Midnight Preview: VIA chain ID `64364450`

VIA's current documentation states that custom Cardano `chain_data` or validator logic requires a matching executor in VIA's off-chain driver and that custom integrations are built with VIA. It also requires a Cardano project-registry registration. See `via/VIA_INTEGRATION.md`.

## Repository

```text
cardano-midnight-omnichain-dao/
├── contracts/
│   └── midnight/
│       └── PrivateDAO.compact
├── cardano/
│   ├── validators/
│   │   ├── voting_adapter.ak
│   │   ├── dao_executor.ak
│   │   └── treasury.ak
│   ├── tests/
│   │   └── executor.ak
│   └── deployment/
│       └── preprod.json
├── via/
│   ├── messages/
│   │   ├── cardano-vote.ts
│   │   ├── execution-auth.ts
│   │   └── execution-result.ts
│   └── VIA_INTEGRATION.md
├── scripts/
│   ├── build-cardano.sh
│   ├── deploy-cardano-preprod.sh
│   ├── deploy-midnight-preview.sh
│   └── e2e-test.ts
├── .env.example
├── .gitignore
└── README.md
```

## 1. Cardano build

Install the current Aiken CLI and Cardano CLI on your development machine. Then:

```bash
npm install
npm run typecheck
npm run build:cardano
```

The Cardano build is network-specific once VIA/network parameters are applied. Do not reuse a Preprod artifact on mainnet.

## 2. Midnight build

Install the current Compact toolchain from Midnight's developer documentation. Then:

```bash
npm run deploy:midnight:preview
```

The deployment script intentionally stops if the Compact CLI is unavailable. The exact generated artifact/deployment command should follow the currently pinned Midnight SDK/toolchain supplied for the Preview environment and VIA integration.

## 3. Fund testnet wallets

Create testnet wallets locally. Keep signing keys outside the repository. Use Cardano Preprod and Midnight Preview faucets/wallet tooling appropriate to the current network.

Never put:

- seed phrases
- mnemonics
- signing keys
- wallet JSON
- API tokens
- VIA credentials

in this repository.

## 4. Deploy Cardano contracts

The intended order is:

1. Build Aiken validators.
2. Obtain script hashes and addresses.
3. Apply any VIA-required compile-time parameters.
4. Create/publish the executor and treasury UTxOs.
5. Record final identities in `cardano/deployment/preprod.json`.
6. Register the Cardano integration with VIA.

`deploy-cardano-preprod.sh` deliberately does not guess unknown VIA parameters or submit an unsafe transaction.

## 5. Deploy PrivateDAO

Deploy `contracts/midnight/PrivateDAO.compact` to Midnight Preview using the current Midnight deployment workflow.

Then configure the Cardano endpoint allowlist with the final Cardano voting endpoint identity.

## 6. VIA custom integration

This is the one part that cannot honestly be fabricated in this repository.

VIA's documentation says custom Cardano logic needs a matching executor in its off-chain driver and that custom integrations are designed together with VIA. Provide `via/VIA_INTEGRATION.md` to VIA together with the deployed endpoint identities and frozen payload definitions.

VIA then supplies/configures the message-layer side required to transport:

- `CARDANO_VOTE`
- `EXECUTION_AUTH`
- `EXECUTION_RESULT`

Do not substitute the publicly documented USDM client for this governance protocol. USDM is a different application.

## 7. End-to-end test

The protocol test produces deterministic application messages:

```bash
npm run protocol:test
```

The live E2E sequence is:

1. Cardano voting adapter creates `CARDANO_VOTE`.
2. VIA delivers it to Midnight.
3. Midnight validates snapshot, nullifier and eligibility.
4. PrivateDAO reaches quorum/threshold.
5. `finalizeProposal` authorizes execution.
6. Midnight creates `EXECUTION_AUTH`.
7. VIA delivers it to Cardano.
8. Cardano materialises/consumes the authorization and executes the exact treasury payment.
9. Cardano creates `EXECUTION_RESULT` containing the transaction ID and action hash.
10. VIA delivers the result to Midnight.
11. PrivateDAO marks the proposal completed.

## Security model

### Replay protection

- Midnight `processedMessages`
- Midnight `voteNullifiers`
- per-proposal execution nonce
- Cardano UTxO consumption

### Action integrity

The action hash commits the complete treasury payment intent. The Cardano executor checks the same fields before paying.

### Timelock

`notBefore` and `expiresAt` are part of the execution authorization. The transaction builder must also enforce the corresponding Cardano validity interval.

### Endpoint allowlisting

Only the VIA-configured Cardano/Midnight endpoint identities are trusted.

### No arbitrary contract calls

V1 has one action kind: `TREASURY_PAYMENT`. New action types should be added as explicit, separately audited branches.

## What is still external

A real end-to-end deployment requires external network resources that cannot be created from this repository alone:

- your funded Preprod wallet
- your deployed Midnight Preview contract identity
- final compiled Cardano script hashes/addresses
- VIA project registration
- VIA custom Cardano off-chain executor/message-layer configuration
- final VIA endpoint identities and protocol parameters

Those values are deliberately represented as `REPLACE_AFTER_*` rather than invented.
