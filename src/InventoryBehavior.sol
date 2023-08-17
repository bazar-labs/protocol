// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./interfaces/IInventoryRegistry.sol";

/// @title InventoryBehavior
/// @notice Abstract contract for inventory behaviors
abstract contract InventoryBehavior {
    address public controller;
    IInventoryRegistry public registry;

    constructor(address _controller, IInventoryRegistry _registry) {
        controller = _controller;
        registry = _registry;
    }

    modifier onlyController() {
        require(msg.sender == controller, "Caller is not the controller");
        _;
    }

    modifier nonPayable() {
        require(msg.value == 0, "Behavior doesn't expect ETH");
        _;
    }

    /// @notice Executes the behavior
    /// @param player Player executing the behavior
    /// @param data ABI-encoded data to pass to behavior
    function execute(address player, bytes calldata data) public payable virtual;
}
