// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "BoringSolidity/BoringFactory.sol";
import "forge-std/console2.sol";
import "forge-std/Script.sol";
import "src/behaviors/PurchaseCurrencyEth.sol";

contract ClonePurchaseCurrencyEth is Script {
    function run() public {
        vm.startBroadcast();

        BoringFactory factory = BoringFactory(vm.envAddress("FACTORY_ADDRESS"));

        // Create a clone of PurchaseCurrencyEth using BoringFactory
        address purchaseCurrencyEthCloneAddress = factory.deploy(
            vm.envAddress("PURCHASE_BEHAVIOR_ADDRESS"),
            abi.encode(
                tx.origin,
                vm.envAddress("CLONE_CONTROLLER_ADDRESS"),
                vm.envAddress("CLONE_REGISTRY_ADDRESS")
            ),
            false
        );
        PurchaseCurrencyEth purchaseCurrencyEthClone =
            PurchaseCurrencyEth(purchaseCurrencyEthCloneAddress);
        console2.log(
            "Clone of PurchaseCurrencyEth deployed to:",
            purchaseCurrencyEthCloneAddress
        );
        console2.log(
            "Owner of clone of PurchaseCurrencyEth:",
            purchaseCurrencyEthClone.owner()
        );
        console2.log(
            "Controller of clone of PurchaseCurrencyEth:",
            purchaseCurrencyEthClone.inventoryController()
        );
        console2.log(
            "Registry of clone of PurchaseCurrencyEth:",
            address(purchaseCurrencyEthClone.inventoryRegistry())
        );

        vm.stopBroadcast();
    }
}
