// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/console2.sol";
import "forge-std/Script.sol";
import "src/behaviors/PurchaseItemEth.sol";

bytes32 constant PURCHASE_CURRENCY_ETH_SALT =
    keccak256(bytes("PurchaseItemEth-1690986475"));

contract DeployPurchaseCurrencyWithEth is Script {
    function setUp() public {}

    function run() public returns (PurchaseItemEth purchaseCurrencyEth) {
        vm.startBroadcast();

        purchaseCurrencyEth =
        new PurchaseItemEth{salt: PURCHASE_CURRENCY_ETH_SALT}(tx.origin, address(0), IInventoryRegistry(address(0)));
        console2.log("PurchaseItemEth Deployed:", address(purchaseCurrencyEth));

        vm.stopBroadcast();
    }
}
