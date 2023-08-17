// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "solmate/auth/Owned.sol";
import "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";
import "./interfaces/IInventoryBehavior.sol";

contract InventoryController is Owned, Initializable {
    mapping(IInventoryBehavior => bool) public isBehaviorEnabled;

    event BehaviorEnabled(IInventoryBehavior indexed behavior);
    event BehaviorDisabled(IInventoryBehavior indexed behavior);
    event BehaviorExecuted(address indexed player, IInventoryBehavior indexed behavior);

    constructor(address _owner) Owned(_owner) {}

    function init(bytes calldata data) external payable initializer {
        owner = abi.decode(data, (address));
    }

    function enable(IInventoryBehavior behavior) public onlyOwner {
        isBehaviorEnabled[behavior] = true;
        emit BehaviorEnabled(behavior);
    }

    function disable(IInventoryBehavior behavior) public onlyOwner {
        isBehaviorEnabled[behavior] = false;
        emit BehaviorDisabled(behavior);
    }

    function execute(IInventoryBehavior behavior, bytes calldata data) public payable {
        require(isBehaviorEnabled[behavior], "Behavior isn't enabled");
        behavior.execute{value: msg.value}(msg.sender, data);
        emit BehaviorExecuted(msg.sender, behavior);
    }
}
