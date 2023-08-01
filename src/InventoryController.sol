// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "solmate/auth/Owned.sol";
import "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

interface IInventoryBehavior {
    function execute(address behavior, bytes calldata data) external payable;
}

contract InventoryController is Owned, Initializable {
    mapping(IInventoryBehavior => bool) public isInventoryBehavior;

    event BehaviorSet(IInventoryBehavior indexed behavior, bool state);

    constructor(address _owner) Owned(_owner) {}

    function init(bytes calldata data) external payable initializer {
        owner = abi.decode(data, (address));
    }

    function setBehavior(IInventoryBehavior behavior, bool state)
        public
        onlyOwner
    {
        isInventoryBehavior[behavior] = state;
        emit BehaviorSet(behavior, state);
    }

    function executeBehavior(IInventoryBehavior behavior, bytes calldata data)
        public
        payable
    {
        require(
            isInventoryBehavior[behavior],
            "Behavior isn't in isInventoryBehavior"
        );
        behavior.execute{value: msg.value}(msg.sender, data);
    }
}
