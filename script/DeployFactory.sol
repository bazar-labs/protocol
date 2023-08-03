// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/console2.sol";
import "forge-std/Script.sol";
import "BoringSolidity/BoringFactory.sol";

bytes32 constant BORING_FACTORY_SALT =
    keccak256(bytes("BoringFactory-1690986475"));

contract DeployBoringFactory is Script {
    function setUp() public {}

    function run() public returns (BoringFactory boringFactory) {
        vm.startBroadcast();

        boringFactory = new BoringFactory{salt: BORING_FACTORY_SALT}();
        console2.log("BoringFactory Deployed:", address(boringFactory));

        vm.stopBroadcast();
    }
}
