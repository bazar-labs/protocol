pragma solidity ^0.8.10;

interface IInventoryBehavior {
    function controller() external view returns (address);
    function execute(address player, bytes memory data) external payable;
    function registry() external view returns (address);
}
