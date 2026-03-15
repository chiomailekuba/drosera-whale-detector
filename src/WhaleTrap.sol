// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "./interfaces/ITrap.sol";
import "./WhaleStore.sol";

contract WhaleTrap is ITrap {
    WhaleStore public constant STORE =
        WhaleStore(0xc8875a6E59871f03f61169A5B7DD907C45b53bbd);
    uint256 public constant MIN_USD = 100_000_000; // 1e8 units, $100,000

    function collect() external view override returns (bytes memory) {
        // STORE.latest() returns a tuple (auto-generated getter for public struct)
        (
            bytes32 alertId,
            address wallet,
            uint256 usdValue,
            uint8 surgeType
        ) = STORE.latest();
        uint256 nonce = STORE.nonce();

        if (alertId == bytes32(0)) {
            return bytes("");
        }

        return
            abi.encode(
                nonce,
                alertId,
                wallet,
                usdValue,
                surgeType
            );
    }

    function shouldRespond(
        bytes[] calldata data
    ) external pure override returns (bool, bytes memory) {
        if (data.length < 2 || data[0].length == 0 || data[1].length == 0) {
            return (false, bytes(""));
        }

        (
            uint256 prevNonce,
            bytes32 prevAlertId,
            address prevWallet,
            uint256 prevUsdValue,
            uint8 prevSurgeType
        ) = abi.decode(data[0], (uint256, bytes32, address, uint256, uint8));

        (
            uint256 currNonce,
            bytes32 currAlertId,
            address currWallet,
            uint256 currUsdValue,
            uint8 currSurgeType
        ) = abi.decode(data[1], (uint256, bytes32, address, uint256, uint8));

        // Only respond if nonce changed and USD value exceeds threshold
        if (currNonce > prevNonce && currUsdValue >= MIN_USD) {
            return (
                true,
                abi.encode(currAlertId, currWallet, currSurgeType, currUsdValue)
            );
        }
        return (false, bytes(""));
    }
}
