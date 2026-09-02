#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
command -v aiken >/dev/null || { echo "aiken is required; install the current Aiken CLI first."; exit 1; }
aiken check
aiken build
mkdir -p build
if command -v aiken >/dev/null; then
  aiken blueprint convert > build/cardano-scripts.json
fi
echo "Cardano build complete. Inspect build/ and generated plutus.json."
