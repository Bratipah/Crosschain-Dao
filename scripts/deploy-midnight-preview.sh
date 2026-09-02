#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
: "${MIDNIGHT_NETWORK:=preview}"
: "${MIDNIGHT_PRIVATE_DAO_ADDRESS:?Set MIDNIGHT_PRIVATE_DAO_ADDRESS after deployment tooling returns it}"

if ! command -v compact >/dev/null 2>&1; then
  echo "Compact compiler CLI not found. Install the current Compact toolchain from Midnight docs."
  exit 1
fi

mkdir -p build/midnight
compact compile contracts/midnight/PrivateDAO.compact build/midnight

echo "Compact compilation completed."
echo "Use the current Midnight deployment/ledger CLI to deploy the generated artifacts to Preview."
echo "Do not paste seed phrases or signing keys into this script."
