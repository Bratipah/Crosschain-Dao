# Testnet deployment checklist

## Local
- [ ] Install current Aiken CLI
- [ ] Install current Cardano CLI
- [ ] Install current Compact/Midnight SDK toolchain
- [ ] `npm install`
- [ ] `npm run typecheck`
- [ ] `npm run protocol:test`
- [ ] `aiken check`
- [ ] `aiken build`

## Cardano Preprod
- [ ] Fund deployer wallet on Preprod
- [ ] Apply VIA-provided network/protocol parameters
- [ ] Build final voting adapter
- [ ] Build final DAO executor
- [ ] Build final treasury
- [ ] Record script hashes/addresses in `cardano/deployment/preprod.json`
- [ ] Publish/reference-script outputs as appropriate
- [ ] Create treasury UTxO

## Midnight Preview
- [ ] Compile PrivateDAO with the current Preview-supported Compact version
- [ ] Deploy contract
- [ ] Record contract identity
- [ ] Configure Cardano endpoint allowlist

## VIA
- [ ] Send `via/VIA_INTEGRATION.md` to VIA
- [ ] Register Cardano project
- [ ] Freeze payload encoding with VIA
- [ ] Receive final endpoint identities
- [ ] VIA configures custom message handling/off-chain executor
- [ ] Configure both directions

## E2E
- [ ] CARDANO_VOTE delivered to Midnight
- [ ] Private vote / nullifier checks
- [ ] FINALIZE
- [ ] EXECUTION_AUTH delivered to Cardano
- [ ] Authorization UTxO accepted
- [ ] Treasury payment executes
- [ ] EXECUTION_RESULT delivered to Midnight
- [ ] Proposal marked completed
