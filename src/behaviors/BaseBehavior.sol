// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../interfaces/IInventoryRegistry.sol";

abstract contract BaseBehavior {
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

    function execute(address player, bytes calldata data) public payable virtual;
}
