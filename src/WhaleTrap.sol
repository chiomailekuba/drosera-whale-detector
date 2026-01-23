// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract WhaleStore {
    struct WhaleAlert {
        bytes32 alertId;
        address wallet;
        uint256 usdValue;
        uint8 surgeType;
    }

    WhaleAlert public latest;

    function pushAlert(
        bytes32 alertId,
        address wallet,
        uint256 usdValue,
        uint8 surgeType
    ) external {
        latest = WhaleAlert(alertId, wallet, usdValue, surgeType);
    }
}
