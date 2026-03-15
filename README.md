# OBIE — Whale Surge Detection Trap (Drosera)

On-Chain Behaviour Intelligence Engine (OBIE) is a proof-of-concept Drosera trap that detects whale surge activity and records alerts on-chain in a deterministic and deploy-safe manner.

This design follows the correct Drosera execution model and avoids non-deterministic or off-chain injected data.

---

## Overview

OBIE detects large capital inflows ("whale activity") and records alerts on-chain.

### USD Value Units

All USD values in WhaleStore and WhaleTrap are represented in 1e8 units (e.g., $100,000 = 100_000_000). The minimum threshold for triggering an alert is set by MIN_USD = 100_000_000.

The system is composed of:

- WhaleStore — on-chain alert buffer
- WhaleTrap — Drosera trap that reads on-chain state
- AlertVault — responder contract that stores alerts permanently
- Off-chain detector — computes whale behavior and writes alerts to chain

All data consumed by Drosera is fully deterministic.

---

## Architecture

```
Off-chain Detector
        |
        | pushAlert()
        v
+-------------------+
|   WhaleStore.sol  |
| on-chain buffer   |
+-------------------+
        |
        | collect()
        v
+-------------------+
|   WhaleTrap.sol   |
| Drosera Trap     |
+-------------------+
        |
        | response payload
        v
+-------------------+
|  AlertVault.sol   |
| permanent storage |
+-------------------+
```

---

## Contract Responsibilities

### WhaleStore.sol

Acts as an on-chain bridge between off-chain intelligence and Drosera.

Stores the most recent alert.

```solidity
latestAlert()
→ (alertId, wallet, usdValue, surgeType)
```

Only deterministic reads are performed by the trap.

---

### WhaleTrap.sol

Implements the Drosera `ITrap` interface.

Responsibilities:

- Reads WhaleStore in `collect()`
- Encodes snapshot deterministically
- Decodes snapshot in `shouldRespond()`
- Returns payload aligned with responder ABI

Payload format:

```
(alertId, wallet, surgeType, usdValue)
```

The order must match both TOML and responder exactly.

---

### AlertVault.sol

Receives alerts from Drosera and stores them permanently.

```solidity
alert(
    bytes32 alertId,
    address wallet,
    uint8 alertType,
    uint256 usdValue
)
```

Duplicate alerts are prevented via `alertId`.

---

## Surge Types

| Type | Description    |
| ---- | -------------- |
| 1    | Capital Surge  |
| 2    | Velocity Surge |
| 3    | Group Surge    |

Current PoC implements Capital Surge detection.

---

## Deployment Steps

### 1. Deploy WhaleStore

```bash
forge create src/WhaleStore.sol:WhaleStore \
  --rpc-url <RPC_URL> \
  --private-key <PRIVATE_KEY> \
  --broadcast
```

Save the deployed address.

---

### 2. Configure WhaleTrap

Update `WhaleTrap.sol` with the deployed WhaleStore address:

```solidity
WhaleStore public constant STORE =
    WhaleStore(0xYOUR_WHALESTORE_ADDRESS);
```

Drosera traps cannot receive constructor parameters.

---

### 3. Deploy AlertVault

```bash
forge create src/AlertVault.sol:AlertVault \
  --rpc-url <RPC_URL> \
  --private-key <PRIVATE_KEY> \
  --broadcast
```

Save the deployed address.

---

### 4. Deploy WhaleTrap

```bash
forge create src/WhaleTrap.sol:WhaleTrap \
  --rpc-url <RPC_URL> \
  --private-key <PRIVATE_KEY> \
  --broadcast
```

---

### 5. Configure drosera.toml

```toml
ethereum_rpc = "https://eth-hoodi.g.alchemy.com/v2/YOUR_KEY"
drosera_rpc = "https://relay.hoodi.drosera.io"
eth_chain_id = 560048
drosera_address = "0x91cB447BaFc6e0EA0F4Fe056F5a9b1F14bb06e5D"

[traps.whale_surge]

path = "out/WhaleTrap.sol/WhaleTrap.json"
response_contract = "0xALERT_VAULT_ADDRESS"
response_function = "alert(bytes32,address,uint8,uint256)"

cooldown_period_blocks = 33
block_sample_size = 2
min_number_of_operators = 1
max_number_of_operators = 2

private_trap = true
whitelist = [
  "0xYOUR_OPERATOR_ADDRESS"
]
```

Important notes:

- `whitelist` must contain operator EOAs
- Do not put SAFE or monitored addresses here
- ABI must match exactly

---

### 6. Apply Trap

```bash
drosera apply
```

Drosera will now begin executing:

- collect()
- shouldRespond()
- alert(...)

---

## Off-Chain Detector Flow

The off-chain service performs:

- block monitoring
- USD valuation
- rolling time window tracking
- surge classification

When a surge is detected:

```solidity
WhaleStore.pushAlert(
    alertId,
    wallet,
    usdValue,
    surgeType
);
```

Drosera later consumes this data deterministically.

---

## Why WhaleStore Is Required

Drosera does not support:

- injected parameters
- custom operator data
- runtime values passed to traps

All trap inputs must originate from:

- on-chain state
- logs
- deterministic reads

WhaleStore converts off-chain intelligence into on-chain truth.

---

## Security Properties

- Deterministic execution
- Planner-safe
- ABI-aligned
- Replay-resistant via alertId
- No off-chain injection
- No reverts on empty samples

---

## Limitations

- Only latest alert stored
- Off-chain detector required
- USD pricing assumed off-chain
- Single-alert buffer

These are acceptable constraints for a PoC.

---

## Future Improvements

- Ring-buffer alert queue
- Velocity surge logic
- Group correlation detection
- DAO-owned WhaleStore
- Merkle-root batched alerts
- Cross-chain monitoring
- Automated escalation responders

---

## Summary

This project demonstrates:

- Correct Drosera trap design
- Deterministic on-chain data sourcing
- Real-world surveillance use case
- Safe responder ABI alignment
- Production-grade architecture pattern

OBIE models how serious monitoring systems should be built on Drosera.

---

## License

MIT
