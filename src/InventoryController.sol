// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "solmate/auth/Owned.sol";
import "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";
import "./interfaces/IInventoryBehavior.sol";

/// @title InventoryController
/// @notice Entry point for players executing inventory behaviors
contract InventoryController is Owned, Initializable {
    mapping(IInventoryBehavior => bool) public isBehaviorEnabled;

    event BehaviorEnabled(IInventoryBehavior indexed behavior);
    event BehaviorDisabled(IInventoryBehavior indexed behavior);
    event BehaviorExecuted(address indexed player, IInventoryBehavior indexed behavior);

    constructor(address _owner) Owned(_owner) {}

    /// @dev Called once after cloned via factory, acts as a constructor
    /// @param data ABI-encoded address of owner
    function init(bytes calldata data) external payable initializer {
        owner = abi.decode(data, (address));
    }

    /// @notice Enables an inventory behavior, allowing it to be executed
    /// @param behavior Behavior to enable
    function enable(IInventoryBehavior behavior) public onlyOwner {
        isBehaviorEnabled[behavior] = true;
        emit BehaviorEnabled(behavior);
    }

    /// @notice Disables an inventory behavior, preventing it from being executed
    /// @param behavior Behavior to disable
    function disable(IInventoryBehavior behavior) public onlyOwner {
        isBehaviorEnabled[behavior] = false;
        emit BehaviorDisabled(behavior);
    }

    /// @notice Executes an inventory behavior
    /// @param behavior Behavior to execute
    /// @param data ABI-encoded data to pass to behavior
    function execute(IInventoryBehavior behavior, bytes calldata data) public payable {
        require(isBehaviorEnabled[behavior], "Behavior isn't enabled");
        behavior.execute{value: msg.value}(msg.sender, data);
        emit BehaviorExecuted(msg.sender, behavior);
    }
}
