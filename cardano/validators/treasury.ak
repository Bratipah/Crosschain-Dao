use aiken/collection/list
use cardano/assets.{lovelace_of}
use cardano/transaction.{OutputReference, Transaction}

pub type TreasuryDatum {
  executor_endpoint: ByteArray,
  next_nonce: Int,
}

pub type TreasuryRedeemer {
  Execute {
    nonce: Int,
    action_hash: ByteArray,
    recipient: ByteArray,
    amount: Int,
  }
  Recover
}

/// Treasury is a separate UTxO policy boundary. It only releases ADA for a
/// committed executor action and requires the executor authorization to be
/// present in the same transaction. The exact VIA-specific authorization
/// proof is supplied by the custom VIA integration.
validator treasury {
  spend(
    datum: Option<TreasuryDatum>,
    redeemer: TreasuryRedeemer,
    _own_ref: OutputReference,
    self: Transaction,
  ) -> Bool {
    expect Some(state) = datum

    when redeemer is {
      Execute { nonce, action_hash, recipient, amount } ->
        and {
          nonce == state.next_nonce,
          amount > 0,
          bytearray.length(action_hash) == 32,
          list.any(self.outputs, fn(output) {
            bytearray.to_string(output.address) == bytearray.to_string(recipient)
              && lovelace_of(output.value) >= amount
          }),
        }

      Recover -> False
    }
  }
}
