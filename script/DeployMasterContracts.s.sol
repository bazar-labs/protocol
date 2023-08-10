// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Script.sol";
import "BoringSolidity/BoringFactory.sol";
import "src/InventoryController.sol";
import "src/InventoryRegistry.sol";
import "src/behaviors/PurchaseItemEth.sol";

contract DeployMasterContracts is Script {
    function run()
        public
        returns (
            BoringFactory factory,
            InventoryController controller,
            InventoryRegistry registry,
            PurchaseItemEth purchase
        )
    {
        vm.startBroadcast();

        // factory
        factory = new BoringFactory();

        // inventory
        registry = new InventoryRegistry(tx.origin);
        controller = new InventoryController(tx.origin);

        // behaviors
        purchase =
        new PurchaseItemEth(tx.origin, address(controller), IInventoryRegistry(address(registry)));

        vm.stopBroadcast();
    }
}
