// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Owned} from "@solmate/auth/Owned.sol";
import {Initializable} from "@openzeppelin/proxy/utils/Initializable.sol";

contract Counter is Owned, Initializable {
    uint256 public number;

    constructor(address _owner) Owned(_owner) {}

    function init(bytes calldata data) external payable initializer {
        owner = abi.decode(data, (address));
    }

    function setNumber(uint256 newNumber) public onlyOwner {
        number = newNumber;
    }

    function increment() public {
        number++;
    }
}
