// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

interface IBaseBehavior {
    function execute(address player, bytes memory data) external payable;
    function inventoryController() external view returns (address);
    function inventoryRegistry() external view returns (address);
}
