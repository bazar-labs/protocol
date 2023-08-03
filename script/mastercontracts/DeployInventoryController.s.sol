// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/console2.sol";
import "forge-std/Script.sol";
import "src/InventoryController.sol";

bytes32 constant INVENTORY_CONTROLLER_SALT =
    keccak256(bytes("InventoryController-1690986475"));

contract DeployInventoryController is Script {
    function setUp() public {}

    function run() public returns (InventoryController inventoryController) {
        vm.startBroadcast();

        inventoryController =
            new InventoryController{salt: INVENTORY_CONTROLLER_SALT}(tx.origin);
        console2.log(
            "InventoryController Deployed:", address(inventoryController)
        );

        vm.stopBroadcast();
    }
}
