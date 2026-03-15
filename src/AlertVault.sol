// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title AlertVault
 * @notice Responder contract for the Drosera Whale Surge Detection Trap.
 *         Receives alerts from Drosera operators and stores them permanently.
 * @dev Called automatically when WhaleTrap.shouldRespond() returns true.
 *      The function signature must match drosera.toml: alert(bytes32,address,uint8,uint256)
 */
contract AlertVault {
    struct AlertRecord {
        bytes32 alertId;
        address wallet;
        uint8 alertType;    // 1=Capital, 2=Velocity, 3=Group
        uint256 usdValue;   // USD value in 1e8 units (e.g., $100,000 = 100_000_000)
        uint256 timestamp;
    }

    /// @notice Total number of alerts recorded
    uint256 public alertCount;

    /// @notice Mapping of alertId to AlertRecord
    mapping(bytes32 => AlertRecord) public alerts;

    /// @notice Mapping to track if an alertId has already been processed
    mapping(bytes32 => bool) public alertExists;

    /// @notice Emitted when a new alert is recorded
    event AlertLogged(
        bytes32 indexed alertId,
        address indexed wallet,
        uint8 indexed alertType,
        uint256 usdValue,
        uint256 timestamp
    );

    /**
     * @notice Receive and store a whale surge alert from Drosera
     * @param alertId Unique identifier for the alert
     * @param wallet The whale wallet address
     * @param alertType Type of surge (1=Capital, 2=Velocity, 3=Group)
     * @param usdValue USD value of the surge in 1e8 units
     */
    function alert(
        bytes32 alertId,
        address wallet,
        uint8 alertType,
        uint256 usdValue
    ) external {
        // Prevent duplicate alerts
        require(!alertExists[alertId], "alert-already-exists");

        alerts[alertId] = AlertRecord({
            alertId: alertId,
            wallet: wallet,
            alertType: alertType,
            usdValue: usdValue,
            timestamp: block.timestamp
        });

        alertExists[alertId] = true;
        alertCount++;

        emit AlertLogged(alertId, wallet, alertType, usdValue, block.timestamp);
    }
}
