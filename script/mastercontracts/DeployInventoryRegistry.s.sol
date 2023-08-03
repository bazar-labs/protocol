// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/console2.sol";
import "forge-std/Script.sol";
import "src/InventoryRegistry.sol";

bytes32 constant INVENTORY_CONTROLLER_SALT =
    keccak256(bytes("InventoryRegistry-1690986475"));

contract DeployInventoryRegistry is Script {
    function setUp() public {}

    function run() public returns (InventoryRegistry inventoryRegistry) {
        vm.startBroadcast();

        inventoryRegistry =
            new InventoryRegistry{salt: INVENTORY_CONTROLLER_SALT}(tx.origin);
        console2.log("InventoryRegistry Deployed:", address(inventoryRegistry));

        vm.stopBroadcast();
    }
}
