// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "BoringSolidity/BoringFactory.sol";
import "forge-std/console2.sol";
import "forge-std/Script.sol";
import "src/InventoryRegistry.sol";

contract MyDeploymentScript is Script {
    function run() public {
        vm.startBroadcast();
        console2.log(address(this));

        BoringFactory factory = BoringFactory(
            0x021DBfF4A864Aa25c51F0ad2Cd73266Fde66199d
        );

        // Deploy InventoryRegistry
        InventoryRegistry inventoryRegistry = new InventoryRegistry(
            0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
        );

        console2.log(
            "InventoryRegistry deployed to:",
            address(inventoryRegistry)
        );
        console2.log("Owner of InventoryRegistry:", inventoryRegistry.owner());
        // Create a clone of InventoryRegistry using BoringFactory
        address inventoryRegistryCloneAddress = factory.deploy(
            address(inventoryRegistry),
            abi.encode(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266),
            false
        );
        InventoryRegistry inventoryRegistryClone = InventoryRegistry(
            inventoryRegistryCloneAddress
        );
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
