// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface Interface {
    event BehaviorSet(address indexed behavior, bool state);
    event Initialized(uint8 version);
    event OwnershipTransferred(address indexed user, address indexed newOwner);

    function executeBehavior(address behavior, bytes memory data)
        external
        payable;
    function init(bytes memory data) external payable;
    function isInventoryBehavior(address) external view returns (bool);
    function owner() external view returns (address);
    function setBehavior(address behavior, bool state) external;
    function transferOwnership(address newOwner) external;
}
