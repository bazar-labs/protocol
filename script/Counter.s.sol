// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {BoringFactory} from "BoringSolidity/BoringFactory.sol";
import {Counter} from "../src/Counter.sol";

contract CounterScript is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();

        BoringFactory fa = new BoringFactory();

        BoringFactory f = BoringFactory(address(fa));

        // Deploy Counter
        Counter c = new Counter(
            0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
        );

        console2.log("Counter deployed to:", address(c));
        console2.log("Owner of Counter:", c.owner());

        // Data for init function of Counter contract
        bytes memory data =
            abi.encode(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);

        // Create a clone of Counter using BoringFactory
        address cc = f.deploy(address(c), data, false);

        console2.log("#################################################");

        // Check if the clone was created successfully
        if (cc == address(0)) {
            console2.log("Clone deployment failed.");
            return;
        }

        Counter ccc = Counter(cc);

        console2.log("Clone of Counter deployed to:", cc);
        console2.log("Owner of clone of Counter:", ccc.owner());
    }
}
