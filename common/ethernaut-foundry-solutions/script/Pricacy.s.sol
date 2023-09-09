// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {Privacy} from "ethernaut/levels/Privacy.sol";

contract CounterScript is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();

        bytes32[3] memory data;
        data[0] = keccak256(abi.encodePacked(tx.origin, "0"));
        data[1] = keccak256(abi.encodePacked(tx.origin, "1"));
        data[2] = keccak256(abi.encodePacked(tx.origin, "2"));
        Privacy victim = new Privacy(data);
    }
}
