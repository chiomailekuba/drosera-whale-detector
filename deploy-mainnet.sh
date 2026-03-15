#!/bin/bash
set -e
WALLET_ADDRESS="0xc93bf33438c9c636fc49cafe1086c2c424507a15"
PROJECT_DIR="/mnt/c/Users/ndohj/2026/drosera-whale-detector"
export PATH="$HOME/.foundry/bin:$HOME/.drosera/bin:$PATH"
echo ""
echo "========================================="
echo "  Drosera Mainnet Deployment"
echo "========================================="
echo ""
if [ -z "$RPC_URL" ]; then echo "ERROR: RPC_URL not set"; exit 1; fi
if [ -z "$PRIVATE_KEY" ]; then echo "ERROR: PRIVATE_KEY not set"; exit 1; fi
echo "RPC_URL and PRIVATE_KEY are set."
echo ""
cd "$PROJECT_DIR"
echo ">>> Step 1: Deploying WhaleStore..."
WHALE_STORE_OUTPUT=$(forge create src/WhaleStore.sol:WhaleStore --rpc-url "$RPC_URL" --private-key "$PRIVATE_KEY" --constructor-args "$WALLET_ADDRESS" --broadcast 2>&1) || { echo "FAILED!"; echo "$WHALE_STORE_OUTPUT"; exit 1; }
echo "$WHALE_STORE_OUTPUT"
WHALE_STORE_ADDRESS=$(echo "$WHALE_STORE_OUTPUT" | grep -oP "Deployed to: \K0x[a-fA-F0-9]{40}")
if [ -z "$WHALE_STORE_ADDRESS" ]; then echo "ERROR: Could not parse WhaleStore address"; exit 1; fi
echo "WhaleStore: $WHALE_STORE_ADDRESS"
echo ""
echo ">>> Step 2: Updating WhaleTrap with WhaleStore address..."
sed -i "s|WhaleStore(0x[a-fA-F0-9]*)|WhaleStore(${WHALE_STORE_ADDRESS})|g" src/WhaleTrap.sol
echo "Done."
echo ""
echo ">>> Step 3: Rebuilding..."
forge build 2>&1
echo ""
echo ">>> Step 4: Deploying AlertVault..."
ALERT_VAULT_OUTPUT=$(forge create src/AlertVault.sol:AlertVault --rpc-url "$RPC_URL" --private-key "$PRIVATE_KEY" --broadcast 2>&1) || { echo "FAILED!"; echo "$ALERT_VAULT_OUTPUT"; exit 1; }
echo "$ALERT_VAULT_OUTPUT"
ALERT_VAULT_ADDRESS=$(echo "$ALERT_VAULT_OUTPUT" | grep -oP "Deployed to: \K0x[a-fA-F0-9]{40}")
if [ -z "$ALERT_VAULT_ADDRESS" ]; then echo "ERROR: Could not parse AlertVault address"; exit 1; fi
echo "AlertVault: $ALERT_VAULT_ADDRESS"
echo ""
echo ">>> Step 5: Deploying WhaleTrap..."
WHALE_TRAP_OUTPUT=$(forge create src/WhaleTrap.sol:WhaleTrap --rpc-url "$RPC_URL" --private-key "$PRIVATE_KEY" --broadcast 2>&1) || { echo "FAILED!"; echo "$WHALE_TRAP_OUTPUT"; exit 1; }
echo "$WHALE_TRAP_OUTPUT"
WHALE_TRAP_ADDRESS=$(echo "$WHALE_TRAP_OUTPUT" | grep -oP "Deployed to: \K0x[a-fA-F0-9]{40}")
if [ -z "$WHALE_TRAP_ADDRESS" ]; then echo "ERROR: Could not parse WhaleTrap address"; exit 1; fi
echo "WhaleTrap: $WHALE_TRAP_ADDRESS"
echo ""
echo ">>> Step 6: Updating drosera.toml..."
echo "ethereum_rpc = \"${RPC_URL}\"" > drosera.toml
echo "drosera_rpc = \"https://relay.ethereum.drosera.io/\"" >> drosera.toml
echo "" >> drosera.toml
echo "[traps.whale_surge_detector]" >> drosera.toml
echo "path = \"out/WhaleTrap.sol/WhaleTrap.json\"" >> drosera.toml
echo "response_contract = \"${ALERT_VAULT_ADDRESS}\"" >> drosera.toml
echo "response_function = \"alert(bytes32,address,uint8,uint256)\"" >> drosera.toml
echo "cooldown_period_blocks = 33" >> drosera.toml
echo "min_number_of_operators = 1" >> drosera.toml
echo "max_number_of_operators = 2" >> drosera.toml
echo "block_sample_size = 1" >> drosera.toml
echo "private_trap = true" >> drosera.toml
echo "whitelist = [\"${WALLET_ADDRESS}\"]" >> drosera.toml
echo "Done."
echo ""
echo "========================================="
echo "  ALL CONTRACTS DEPLOYED!"
echo "========================================="
echo "  WhaleStore:  $WHALE_STORE_ADDRESS"
echo "  AlertVault:  $ALERT_VAULT_ADDRESS"
echo "  WhaleTrap:   $WHALE_TRAP_ADDRESS"
echo "========================================="
echo ""
echo "NEXT: Run this command:"
echo "  drosera apply --ethereum-rpc \$RPC_URL --private-key \$PRIVATE_KEY"
