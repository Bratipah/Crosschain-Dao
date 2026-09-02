use cardano_midnight_omnichain_dao/dao_executor

test valid_treasury_authorization() {
  dao_executor.valid_authorization(dao_executor.Authorization {
    source_chain: 64364450,
    source_endpoint: #"0000000000000000000000000000000000000000000000000000000000000000",
    proposal_id: #"0000000000000000000000000000000000000000000000000000000000000001",
    nonce: 7,
    action_kind: dao_executor.TreasuryPayment,
    recipient: #"00000000000000000000000000000000000000000000000000000000",
    amount: 2_000_000,
    action_hash: #"2222222222222222222222222222222222222222222222222222222222222222",
    not_before: 0,
    expires_at: 100,
  })
}
