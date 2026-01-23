import "./WhaleStore.sol";

contract WhaleTrap is ITrap {

    WhaleStore public constant STORE = 0x5ABa4F78caFf521b2696F359BFf946f9C6fD0eFd;

    function collect() external view override returns (bytes memory) {
        (
            bytes32 alertId,
            address wallet,
            uint256 usdValue,
            uint8 surgeType
        ) = STORE.latestAlert();

        if (alertId == bytes32(0)) {
            return bytes("");
        }

        return abi.encode(alertId, wallet, usdValue, surgeType);
    }

    function shouldRespond(
        bytes[] calldata data
    ) external pure override returns (bool, bytes memory) {

        if (data.length == 0 || data[0].length == 0) {
            return (false, bytes(""));
        }

        (
            bytes32 alertId,
            address wallet,
            uint256 usdValue,
            uint8 surgeType
        ) = abi.decode(data[0], (bytes32, address, uint256, uint8));

        return (true, abi.encode(alertId, wallet, surgeType, usdValue));
    }
}
