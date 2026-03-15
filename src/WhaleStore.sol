// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract WhaleStore {
    struct WhaleAlert {
        bytes32 alertId;
        address wallet;
        uint256 usdValue; // Value in USD, units: 1e8 (e.g., $100,000 = 100_000_000)
        uint8 surgeType;
    }

    WhaleAlert public latest;
    uint256 public nonce;
    address public writer;

    constructor(address _writer) {
        writer = _writer;
    }

    function pushAlert(
        bytes32 alertId,
        address wallet,
        uint256 usdValue,
        uint8 surgeType
    ) external {
        require(msg.sender == writer, "not-writer");
        latest = WhaleAlert(alertId, wallet, usdValue, surgeType);
        nonce++;
    }
}
