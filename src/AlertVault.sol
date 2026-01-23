// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "./interfaces/ITrap.sol";

interface IWhaleStore {
    function latest()
        external
        view
        returns (
            bytes32 alertId,
            address wallet,
            uint256 usdValue,
            uint8 surgeType
        );
}

contract WhaleTrap is ITrap {
    address public constant STORE =
        0x0000000000000000000000000000000000000000; // set after deploy

    uint256 public constant MIN_USD = 100_000e18;

    function collect()
        external
        view
        override
        returns (bytes memory)
    {
        (
            bytes32 alertId,
            address wallet,
            uint256 usdValue,
            uint8 surgeType
        ) = IWhaleStore(STORE).latest();

        return abi.encode(alertId, wallet, usdValue, surgeType);
    }

    function shouldRespond(
        bytes[] calldata data
    )
        external
        pure
        override
        returns (bool, bytes memory)
    {
        if (data.length == 0 || data[0].length == 0) {
            return (false, bytes(""));
        }

        (
            bytes32 alertId,
            address wallet,
            uint256 usdValue,
            uint8 surgeType
        ) = abi.decode(data[0], (bytes32, address, uint256, uint8));

        if (usdValue < MIN_USD) {
            return (false, bytes(""));
        }

        // IMPORTANT: responder expects:
        // alert(bytes32,address,uint8,uint256)

        return (
            true,
            abi.encode(alertId, wallet, surgeType, usdValue)
        );
    }
}
