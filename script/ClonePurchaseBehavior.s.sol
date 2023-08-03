// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "BoringSolidity/BoringFactory.sol";
import "forge-std/console2.sol";
import "forge-std/Script.sol";
import "src/behaviors/PurchaseItemEth.sol";

contract ClonePurchaseItemEth is Script {
    function run() public {
        vm.startBroadcast();

        BoringFactory factory = BoringFactory(vm.envAddress("FACTORY_ADDRESS"));

        // Create a clone of PurchaseItemEth using BoringFactory
        address purchaseItemEthCloneAddress = factory.deploy(
            vm.envAddress("PURCHASE_BEHAVIOR_ADDRESS"),
            abi.encode(
                tx.origin,
                vm.envAddress("CLONE_CONTROLLER_ADDRESS"),
                vm.envAddress("CLONE_REGISTRY_ADDRESS")
            ),
            false
        );
        PurchaseItemEth purchaseItemEthClone =
            PurchaseItemEth(purchaseItemEthCloneAddress);
        console2.log(
            "Clone of PurchaseItemEth deployed to:", purchaseItemEthCloneAddress
        );
        console2.log(
            "Owner of clone of PurchaseItemEth:", purchaseItemEthClone.owner()
        );
        console2.log(
            "Controller of clone of PurchaseItemEth:",
            purchaseItemEthClone.inventoryController()
        );
        console2.log(
            "Registry of clone of PurchaseItemEth:",
            address(purchaseItemEthClone.inventoryRegistry())
        );

        vm.stopBroadcast();
    }
}
