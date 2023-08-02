// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "BoringSolidity/BoringFactory.sol";
import "forge-std/console2.sol";
import "forge-std/Script.sol";
import "src/InventoryRegistry.sol";

contract CloneInventoryController is Script {
    function run() public {
        vm.startBroadcast();

        BoringFactory factory = BoringFactory(vm.envAddress("FACTORY_ADDRESS"));

        // Create a clone of InventoryRegistry using BoringFactory
        address inventoryRegistryCloneAddress = factory.deploy(
            vm.envAddress("CONTROLLER_ADDRESS"), abi.encode(tx.origin), false
        );
        InventoryRegistry inventoryRegistryClone =
            InventoryRegistry(inventoryRegistryCloneAddress);
        console2.log(
            "Clone of InventoryRegistry deployed to:",
            inventoryRegistryCloneAddress
        );
        console2.log(
            "Owner of clone of InventoryRegistry:",
            inventoryRegistryClone.owner()
        );

        vm.stopBroadcast();
    }
}