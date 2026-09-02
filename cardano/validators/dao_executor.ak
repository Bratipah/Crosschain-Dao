use aiken/collection/list
use cardano/address
use cardano/assets.{lovelace_of}
use cardano/transaction.{OutputReference, Transaction}
use aiken/crypto.{VerificationKeyHash}

pub type ActionKind {
  TreasuryPayment
}

pub type Authorization {
  source_chain: Int,
  source_endpoint: ByteArray,
  proposal_id: ByteArray,
  nonce: Int,
  action_kind: ActionKind,
  recipient: VerificationKeyHash,
  amount: Int,
  action_hash: ByteArray,
  not_before: Int,
  expires_at: Int,
}

pub type Redeemer {
  ExecuteTreasury(Authorization)
  Cancel
}

/// Executor validates the exact action committed by Midnight.
/// VIA is expected to materialise the authorization UTxO after authenticated
/// delivery of EXECUTION_AUTH. The executor then consumes that UTxO and pays
/// the exact recipient. This is intentionally NOT an arbitrary-call executor.
validator dao_executor {
  spend(
    datum: Option<Authorization>,
    redeemer: Redeemer,
    _own_ref: OutputReference,
    self: Transaction,
  ) -> Bool {
    expect Some(auth) = datum

    when redeemer is {
      ExecuteTreasury(request) ->
        and {
          request.source_chain == auth.source_chain,
          request.source_endpoint == auth.source_endpoint,
          request.proposal_id == auth.proposal_id,
          request.nonce == auth.nonce,
          request.action_kind == auth.action_kind,
          request.recipient == auth.recipient,
          request.amount == auth.amount,
          request.action_hash == auth.action_hash,
          request.not_before == auth.not_before,
          request.expires_at == auth.expires_at,
          request.amount > 0,
          bytearray.length(request.proposal_id) == 32,
          bytearray.length(request.action_hash) == 32,
          request.expires_at >= request.not_before,
          list.any(self.outputs, fn(output) {
            output.address == address.from_verification_key(request.recipient)
              && lovelace_of(output.value) >= request.amount
          }),
        }

      Cancel -> bytearray.length(auth.proposal_id) == 32
    }
  }
}

pub fn valid_authorization(a: Authorization) -> Bool {
  a.action_kind == TreasuryPayment
    && a.amount > 0
    && bytearray.length(a.proposal_id) == 32
    && bytearray.length(a.action_hash) == 32
    && a.expires_at >= a.not_before
}

test rejects_zero_amount() {
  let a = Authorization {
    source_chain: 64364450,
    source_endpoint: #"0000000000000000000000000000000000000000000000000000000000000000",
    proposal_id: #"0000000000000000000000000000000000000000000000000000000000000001",
    nonce: 1,
    action_kind: TreasuryPayment,
    recipient: #"",
    amount: 0,
    action_hash: #"1111111111111111111111111111111111111111111111111111111111111111",
    not_before: 0,
    expires_at: 10,
  }
  !valid_authorization(a)
}

test accepts_positive_amount() {
  let a = Authorization {
    source_chain: 64364450,
    source_endpoint: #"0000000000000000000000000000000000000000000000000000000000000000",
    proposal_id: #"0000000000000000000000000000000000000000000000000000000000000001",
    nonce: 1,
    action_kind: TreasuryPayment,
    recipient: #"00000000000000000000000000000000000000000000000000000000",
    amount: 1_000_000,
    action_hash: #"1111111111111111111111111111111111111111111111111111111111111111",
    not_before: 0,
    expires_at: 10,
  }
  valid_authorization(a)
}
