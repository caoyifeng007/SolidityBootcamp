// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";

contract AlienCodexScript is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();

        bytes memory bytecode = abi.encodePacked(
            vm.getCode("AlienCodex.sol:AlienCodex")
        );
        address contractAddr;
        assembly {
            contractAddr := create(0, add(bytecode, 0x20), mload(bytecode))
        }
    }
}
