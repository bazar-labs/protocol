// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "solmate/auth/Owned.sol";
import "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";
import "./interfaces/IBaseBehavior.sol";

contract InventoryController is Owned, Initializable {
    mapping(IBaseBehavior => bool) public isBehaviorEnabled;

    event BehaviorEnabled(IBaseBehavior indexed behavior);
    event BehaviorDisabled(IBaseBehavior indexed behavior);
    event BehaviorExecuted(address indexed player, IBaseBehavior indexed behavior);

    constructor(address _owner) Owned(_owner) {}

    function init(bytes calldata data) external payable initializer {
        owner = abi.decode(data, (address));
    }

    function enable(IBaseBehavior behavior) public onlyOwner {
        isBehaviorEnabled[behavior] = true;
        emit BehaviorEnabled(behavior);
    }

    function disable(IBaseBehavior behavior) public onlyOwner {
        isBehaviorEnabled[behavior] = false;
        emit BehaviorDisabled(behavior);
    }

    function execute(IBaseBehavior behavior, bytes calldata data) public payable {
        require(isBehaviorEnabled[behavior], "Behavior isn't enabled");
        behavior.execute{value: msg.value}(msg.sender, data);
        emit BehaviorExecuted(msg.sender, behavior);
    }
}
