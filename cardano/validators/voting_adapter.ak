use aiken/collection/list
use cardano/transaction.{OutputReference, Transaction}

pub type Vote {
  Yes
  No
  Abstain
}

pub type VoteMessage {
  message_id: ByteArray,
  source_endpoint: ByteArray,
  proposal_id: ByteArray,
  vote_nullifier: ByteArray,
  support: Vote,
  voting_power: Int,
  snapshot: Int,
}

pub type Redeemer {
  SendVote(VoteMessage)
}

/// Cardano-side adapter. It does not decide governance. Its job is to bind a
/// local vote to a deterministic VIA CARDANO_VOTE payload. VIA's message layer
/// then transports the payload to Midnight.
validator voting_adapter {
  spend(
    datum: Option<ByteArray>,
    redeemer: Redeemer,
    _own_ref: OutputReference,
    self: Transaction,
  ) -> Bool {
    expect Some(endpoint) = datum

    when redeemer is {
      SendVote(m) ->
        and {
          m.source_endpoint == endpoint,
          bytearray.length(m.message_id) == 32,
          bytearray.length(m.proposal_id) == 32,
          bytearray.length(m.vote_nullifier) == 32,
          m.voting_power > 0,
          m.snapshot >= 0,
          list.length(self.inputs) > 0,
        }
    }
  }
}
