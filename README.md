# Cardano ↔ Midnight Cross-Chain DAO Governance

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![Aiken](https://img.shields.io/badge/Aiken-v1.0.0-blue)](https://aiken-lang.org/)
[![Midnight](https://img.shields.io/badge/Midnight-Compact-orange)](https://midnight.network/)

A production-ready cross-chain DAO governance protocol that enables **private voting on Midnight** with **deterministic treasury execution on Cardano**.

## 🎯 Overview

This project implements a two-way governance protocol where:

- **Cardano** provides assets, voters, and treasury execution
- **Midnight** provides private/shielded governance and decision-making
- **VIA** transports authenticated governance messages between chains
- **Cardano's Aiken executor** enforces finalized decisions on-chain

### Core Principle

> **Midnight decides privately; Cardano executes deterministically.**

## 📋 Table of Contents

- [Why This Exists](#why-this-exists)
- [Architecture](#architecture)
- [Key Components](#key-components)
- [Governance Lifecycle](#governance-lifecycle)
- [Security Model](#security-model)
- [Message Types](#message-types)
- [Repository Structure](#repository-structure)
- [Getting Started](#getting-started)
- [Testing](#testing)
- [Deployment](#deployment)
- [Contributing](#contributing)
- [License](#license)

## 🤔 Why This Exists

### Problem 1: Public Governance Exposes Voter Information

Traditional DAO voting publicly associates votes with addresses, creating problems with voter privacy, political/social pressure, voter profiling, strategic voting, and targeted attacks.

**Our solution:** Use Midnight's privacy model with zero-knowledge proofs and nullifiers. Votes prove eligibility without revealing identity.

### Problem 2: Different Blockchains Have Different Strengths

Cardano excels at assets and deterministic execution; Midnight excels at privacy and zero-knowledge proofs.

**Our solution:** Give each chain its specialized role in the governance process.

### Problem 3: Authentication Across Chains

A malicious relayer could claim Midnight approved an action it didn't.

**Our solution:** Action hash commitments ensure Cardano executes only exactly what Midnight authorized.

### Problem 4: Replay Attacks

An attacker could capture and resubmit execution authorizations.

**Our solution:** Nonces ensure each proposal/nonce combination can execute only once.

### Problem 5: Immediate Execution Risk

Proposals executing immediately after passing is dangerous.

**Our solution:** Timelocks provide a safety window for monitoring and emergency cancellation.

## 🏗️ Architecture

```
                    CARDANO
                       │
                voting activity
                       │
                       ▼
               Voting Adapter
                       │
                  CARDANO_VOTE
                       │
                       ▼
                      VIA
                       │
                       ▼
                  MIDNIGHT
                       │
              ┌────────┴────────┐
              │                 │
        private eligibility   nullifier
              │                 │
              └────────┬────────┘
                       │
                 private voting
                       │
                       ▼
                    QUORUM
                       │
                       ▼
                    FINALIZE
                       │
                       ▼
              EXECUTION_AUTH
                       │
                       ▼
                      VIA
                       │
                       ▼
                    CARDANO
                       │
                DAO Executor
                       │
             verify actionHash
                       │
              verify nonce
                       │
              verify timelock
                       │
                       ▼
                 Treasury UTxO
                       │
                       ▼
              TREASURY_PAYMENT
                       │
                       ▼
                  Recipient
                       │
                       ▼
              EXECUTION_RESULT
                       │
                       ▼
                      VIA
                       │
                       ▼
                   MIDNIGHT
                       │
                       ▼
                  COMPLETED
```

### Role Distribution

| Component | Responsibility |
|-----------|----------------|
| Cardano | Assets + treasury management |
| Cardano Voting Adapter | Convert voting activity into governance messages |
| Midnight | Private governance processing |
| PrivateDAO | Proposals + private voting + finalization |
| VIA | Cross-chain message transport |
| Cardano Executor | Enforce finalized actions |
| Cardano Treasury | Hold DAO funds |

## 🧩 Key Components

### PrivateDAO (Midnight Compact)

The governance brain handling:
- Proposals
- Private votes with nullifiers
- Eligibility verification
- Quorum and threshold calculations
- Finalization
- Execution authorization
- Execution result verification

### Voting Adapter (Cardano Aiken)

Turns Cardano governance activity into VIA-transportable messages:
- Captures votes with proposal IDs, voter commitments, and voting power
- Handles snapshot verification
- Prevents double voting

### DAO Executor (Cardano Aiken)

The security gate that ensures Cardano executes only authorized actions:
- Verifies action hash matches
- Confirms source authorization
- Enforces timelocks
- Prevents replay attacks (nonce verification)
- Checks execution status

### Treasury (Cardano Aiken)

Controls DAO treasury UTxOs:
- Intentionally simple—no complex governance logic
- Validates spending authorizations
- Records executed proposals

### Message Schemas (VIA)

Defines the protocol messages:
- `CARDANO_VOTE` (Cardano → Midnight)
- `EXECUTION_AUTH` (Midnight → Cardano)
- `EXECUTION_RESULT` (Cardano → Midnight)

## 🔄 Governance Lifecycle

### 1. Proposal Creation
Anyone creates a proposal in the PrivateDAO (e.g., treasury payment of 1,000 ADA to a specific recipient).

### 2. Cardano Voting
Voters interact with the Voting Adapter, which creates `CARDANO_VOTE` messages containing proposal IDs, voter commitments, voting power, and nonces.

### 3. Transport to Midnight
`CARDANO_VOTE` messages travel through VIA to Midnight.

### 4. Private Vote Processing
PrivateDAO checks eligibility, nullifiers, and records votes privately.

### 5. Vote Aggregation
After voting closes, PrivateDAO checks quorum and approval thresholds.

### 6. Finalization
If the proposal passes, it moves from VOTING to FINALIZED status.

### 7. Execution Authorization
Midnight generates `EXECUTION_AUTH` with proposal ID, nonce, action details, timelock, and action hash.

### 8. Transport to Cardano
`EXECUTION_AUTH` travels through VIA to the DAO Executor.

### 9. Cardano Verification
The DAO Executor verifies source, proposal, nonce, action hash, timelock, and execution status.

### 10. Treasury Execution
The treasury UTxO is consumed, producing payment to the recipient.

### 11. Execution Result
Cardano produces `EXECUTION_RESULT` and sends it through VIA to Midnight.

### 12. Completion Recording
PrivateDAO marks the execution as completed.

## 🔒 Security Model

### Core Invariant

> **Cardano must never execute an action merely because a relayer says Midnight approved it. Cardano executes only when the authorization corresponds exactly to the committed governance action and satisfies all local execution rules.**

### Security Properties

| Property | Mechanism |
|----------|-----------|
| **Authorization** | Action hash commitments |
| **Replay Prevention** | Nonces |
| **Source Authentication** | Endpoint allowlisting |
| **Timing Safety** | Timelocks |
| **Voter Privacy** | ZK proofs + nullifiers |
| **Execution Verification** | Action hash recomputation |
| **UTxO Integrity** | eUTxO model validation |

### Security Layers

```
Midnight authorization
        +
action commitment
        +
VIA delivery
        +
Cardano verification
        +
timelock
        +
nonce
        +
UTxO authorization
        =
controlled execution
```

## 📨 Message Types

### CARDANO_VOTE (Cardano → Midnight)

```typescript
{
  proposalId:     number,
  voterCommitment: bytes,
  vote:           Vote { YES | NO | ABSTAIN },
  votingPower:    number,
  snapshot:       number,
  nonce:          number
}
```

**Purpose:** "A valid Cardano governance vote has occurred."

### EXECUTION_AUTH (Midnight → Cardano)

```typescript
{
  proposalId:   number,
  nonce:        number,
  actionType:   "TREASURY_PAYMENT",
  recipient:    Address,
  amount:       number,
  notBefore:    Timestamp,
  actionHash:   bytes,
  executor:     Address
}
```

**Purpose:** "Private governance finalized this exact Cardano action."

### EXECUTION_RESULT (Cardano → Midnight)

```typescript
{
  proposalId:   number,
  nonce:        number,
  actionHash:   bytes,
  status:       "SUCCESS" | "FAILURE",
  txHash:       bytes
}
```

**Purpose:** "Cardano actually executed this exact authorized action."

## 📁 Repository Structure

```
├── contracts/
│   └── midnight/
│       └── PrivateDAO.compact    # Midnight governance contract
│
├── cardano/
│   ├── validators/
│   │   ├── voting_adapter.ak     # Cardano → Midnight adapter
│   │   ├── dao_executor.ak       # Security gate
│   │   └── treasury.ak           # Treasury management
│   └── tests/
│       └── executor.ak           # Security test suite
│
├── via/
│   └── messages/
│       ├── cardano_vote.schema
│       ├── execution_auth.schema
│       └── execution_result.schema
│
├── docs/
│   ├── architecture.md
│   ├── security.md
│   └── integration.md
│
├── README.md
├── LICENSE
└── package.json
```

## 🚀 Getting Started

### Prerequisites

- [Aiken](https://aiken-lang.org/) v1.0.0+
- [Midnight Compact](https://midnight.network/) compiler
- [Node.js](https://nodejs.org/) v18+ (for VIA integration)
- [Deno](https://deno.com/) (for testing)

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/cardano-midnight-dao.git
cd cardano-midnight-dao

# Install dependencies
npm install

# Build Aiken contracts
aiken build cardano/

# Compile Midnight contract
compact build contracts/midnight/PrivateDAO.compact
```

### Testing

```bash
# Run Cardano validator tests
aiken test cardano/tests/

# Run integration tests
npm test
```

### Deployment

#### Cardano Contracts

```bash
# Build and deploy to Preprod
aiken deploy cardano/validators/ --network preprod

# Deploy treasury
aiken deploy cardano/validators/treasury.ak --network preprod
```

#### Midnight Contract

```bash
# Deploy to Midnight Preview
compact deploy contracts/midnight/PrivateDAO.compact --network preview
```

#### VIA Configuration

Configure endpoint allowlisting in VIA configuration:

```yaml
endpoints:
  cardano_vote:
    source: Cardano-Preprod
    destination: Midnight-Preview
    allowed: true
    
  execution_auth:
    source: Midnight-Preview
    destination: Cardano-Preprod
    allowed: true
    
  execution_result:
    source: Cardano-Preprod
    destination: Midnight-Preview
    allowed: true
```

## 🧪 Test Coverage

Security tests verify:

- ✅ Wrong recipient → REJECT
- ✅ Wrong amount → REJECT
- ✅ Wrong hash → REJECT
- ✅ Wrong nonce → REJECT
- ✅ Replay attacks → REJECT
- ✅ Before timelock → REJECT
- ✅ Unauthorized source → REJECT
- ✅ Correct authorization → EXECUTE
- ✅ Completed proposal → REJECT

## 📚 Documentation

- [Architecture Deep Dive](./Architecture.md)
- [Deployment](./DEPLOYMENT_CHECKLIST.md)
- [Integration Guide](docs/integration.md)
- [Via Workflow](./via/VIA_INTEGRATION.md)

## 🔧 Integration Boundary

The repository implements:
- Midnight PrivateDAO
- Cardano voting adapter
- Cardano DAO executor
- Cardano treasury
- Message schemas
- Transaction construction
- Tests

VIA implements:
- Endpoint configuration
- Route registration
- Custom message handling
- Cardano off-chain executor
- Relayer infrastructure

This separation ensures clear ownership and maintainability.

## 🌟 Why This Architecture Matters

### Separation of Concerns

Each chain does what it does best:
- Cardano: Assets and deterministic execution
- Midnight: Privacy and governance
- VIA: Communication

### Complete Governance Loop

Unlike simpler cross-chain voting systems, this creates a **closed governance-execution loop**:

```
Cardano → Midnight (votes)
Midnight → Cardano (authorization)
Cardano → Midnight (execution result)
```

### Production-Ready Security

- Multi-layer authentication
- Replay protection
- Timelock safety
- UTxO-based validation
- Cryptographic commitments

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development Workflow

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

### Code Style

- Aiken: Follow [Aiken style guide](https://aiken-lang.org/guides/style-guide)
- Midnight: Follow [Compact style guide](https://midnight.network/docs/style-guide)
- Tests: Coverage should remain at 100%

## 📄 License

This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [Cardano](https://cardano.org/) for the secure UTxO model
- [Midnight](https://midnight.network/) for private smart contracts
- [VIA](https://via.network/) for cross-chain interoperability
- [Aiken](https://aiken-lang.org/) for Cardano smart contract development

---

## 📞 Contact & Support

- **Issues**: [GitHub Issues](https://github.com/Bratipah/cardano-midnight-crosschain-dao/issues)


---

**Built with ❤️ on Cardano & Midnight**