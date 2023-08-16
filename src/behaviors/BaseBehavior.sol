// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../interfaces/IInventoryRegistry.sol";

abstract contract BaseBehavior {
    address public inventoryController;
    IInventoryRegistry public inventoryRegistry;

    constructor(address inventoryController_, IInventoryRegistry inventoryRegistry_) {
        inventoryController = inventoryController_;
        inventoryRegistry = inventoryRegistry_;
    }

    modifier onlyGame() {
        require(msg.sender == inventoryController, "Caller is not the game");
        _;
    }

    modifier nonPayable() {
        require(msg.value == 0, "Behavior doesn't expect ETH");
        _;
    }

    function execute(address player, bytes calldata data) public payable virtual;
}
