#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
: "${CARDANO_NODE_SOCKET_PATH:?Set CARDANO_NODE_SOCKET_PATH}"
: "${CARDANO_PAYMENT_SKEY:?Set CARDANO_PAYMENT_SKEY to a LOCAL secret-key file}"
: "${CARDANO_PREPROD_MAGIC:=1}"
command -v cardano-cli >/dev/null || { echo "cardano-cli is required."; exit 1; }
command -v aiken >/dev/null || { echo "aiken is required."; exit 1; }

./scripts/build-cardano.sh

mkdir -p build/preprod
# Aiken emits the final blueprint. Convert the selected validator to a script
# with the installed Aiken version before computing its address.
aiken blueprint convert > build/preprod/plutus.json

echo "Build succeeded."
echo "Next: apply any compile-time parameters required by your VIA integration,"
echo "derive the final script hashes/addresses, then fund and publish reference scripts."
echo "This script intentionally does not sign or submit a transaction with an"
echo "unknown script hash or unknown VIA parameters."
