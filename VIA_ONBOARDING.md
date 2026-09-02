# VIA Integration Handoff

This document is the exact boundary to take to VIA when requesting a custom Cardano ↔ Midnight governance integration.

## Requested route

```text
Cardano Preprod (2273266)
        ↕
Midnight Preview (64364450)
```

## Application

Cross-chain DAO governance:

```text
Cardano vote → Midnight private aggregation/finalization
Midnight execution authorization → Cardano treasury executor
Cardano execution result → Midnight completion receipt
```

## Cardano source message

Application type: `CARDANO_VOTE`

Fields:

```text
version
messageId
proposalId
sourceChainId
sourceEndpoint
voteNullifier
support
votingPower
snapshot
```

The Cardano governance adapter must produce a VIA `send_request` UTxO containing the agreed `chain_data`.

## Midnight destination

The Midnight application consumes the authenticated application message and invokes:

```text
processCardanoVote(...)
```

The final VIA integration must provide:

- Cardano endpoint identity
- relayer configuration
- route configuration
- message authentication
- final Compact client wiring

## Midnight source message

Application type: `EXECUTION_AUTH`

Fields:

```text
version
proposalId
sourceChainId
destinationChainId
sourceEndpoint
executor
actionKind
recipient
amount
actionHash
nonce
notBefore
expiresAt
```

The first action type is:

```text
TREASURY_PAYMENT
```

## Cardano destination

The receive-side integration should materialize an authorization UTxO carrying:

```text
AuthorizationDatum {
  via_source_chain,
  via_source_endpoint,
  proposal_id,
  nonce,
  action_kind,
  recipient,
  amount,
  action_hash,
  not_before,
  expires_at
}
```

The DAO executor then consumes this authorization together with the treasury UTxO.

## Cardano result message

Application type: `EXECUTION_RESULT`

Fields:

```text
version
messageId
proposalId
sourceChainId
sourceExecutor
nonce
success
actionHash
```

## Required VIA deliverables

Request the following before production deployment:

1. final Cardano custom client/executor package
2. final Midnight VIA client package/configuration
3. Preprod project registry configuration
4. Cardano protocol policy IDs / state UTxO configuration
5. approved source/destination endpoint IDs
6. exact `chain_data` encoding
7. message fee configuration
8. confirmation requirements
9. relayer configuration and operational procedure
10. testnet acceptance criteria

VIA's public documentation states that custom Cardano message logic requires a matching executor in the off-chain driver and that custom integrations are built together with VIA. It likewise describes custom Midnight integrations as guided integrations. Do not replace those components with an unofficial implementation. 
