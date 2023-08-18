// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Script.sol";
import "BoringSolidity/BoringFactory.sol";
import "src/InventoryController.sol";
import "src/InventoryRegistry.sol";
import "src/behaviors/PurchaseItemWithETH.sol";

contract DeployMasterContracts is Script {
    function run()
        public
        returns (BoringFactory factory, InventoryRegistry registry, InventoryController controller, PurchaseItemWithETH purchase)
    {
        vm.startBroadcast();

        // factory
        factory = new BoringFactory();

        // inventory
        registry = new InventoryRegistry(tx.origin);
        controller = new InventoryController(tx.origin);

        // behaviors
        purchase = new PurchaseItemWithETH(tx.origin, address(controller), IInventoryRegistry(address(registry)));

        vm.stopBroadcast();
    }
}
