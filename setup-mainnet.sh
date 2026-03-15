#!/bin/bash
set -e

echo "========================================="
echo "  Drosera Mainnet Setup Script"
echo "========================================="
echo ""

# Add foundry to PATH
export PATH="$HOME/.foundry/bin:$HOME/.drosera/bin:$PATH"

# Step 1: Install Foundry
echo ">>> Step 1: Installing Foundry..."
if command -v forge &> /dev/null; then
    echo "    forge already installed: $(forge --version)"
else
    echo "    Running foundryup..."
    foundryup
    echo "    forge installed: $(forge --version)"
fi
echo ""

# Step 2: Install Drosera CLI
echo ">>> Step 2: Installing Drosera CLI..."
if command -v drosera &> /dev/null; then
    echo "    drosera already installed: $(drosera --version)"
else
    echo "    Downloading droseraup installer..."
    curl -L https://app.drosera.io/install 2>/dev/null | bash
    export PATH="$HOME/.drosera/bin:$PATH"
    echo "    Running droseraup..."
    droseraup
    echo "    drosera installed: $(drosera --version)"
fi
echo ""

# Step 3: Verify everything
echo ">>> Step 3: Verifying installations..."
echo "    forge: $(which forge 2>/dev/null || echo 'NOT FOUND')"
echo "    cast:  $(which cast 2>/dev/null || echo 'NOT FOUND')"
echo "    drosera: $(which drosera 2>/dev/null || echo 'NOT FOUND')"
echo ""

# Step 4: Build contracts
echo ">>> Step 4: Building contracts..."
cd /mnt/c/Users/ndohj/2026/drosera-whale-detector
forge build
echo ""

echo "========================================="
echo "  Setup Complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo "  1. Get an Ethereum mainnet RPC URL from Alchemy"
echo "  2. Make sure you have ETH in your wallet"
echo "  3. Purchase a Drosera subscription"
echo "  4. Deploy contracts (see mainnet_deployment_guide.md)"
