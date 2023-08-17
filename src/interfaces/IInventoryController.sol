pragma solidity ^0.8.10;

interface IInventoryController {
    event BehaviorDisabled(address indexed behavior);
    event BehaviorEnabled(address indexed behavior);
    event BehaviorExecuted(address indexed player, address indexed behavior);
    event Initialized(uint8 version);
    event OwnershipTransferred(address indexed user, address indexed newOwner);

    function disable(address behavior) external;
    function enable(address behavior) external;
    function execute(address behavior, bytes memory data) external payable;
    function init(bytes memory data) external payable;
    function isBehaviorEnabled(address) external view returns (bool);
    function owner() external view returns (address);
    function transferOwnership(address newOwner) external;
}
