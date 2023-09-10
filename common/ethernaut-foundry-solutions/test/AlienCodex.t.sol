// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

import {AlienCodex, AlienCodexAttacker} from "../src/AlienCodex/AlienCodexAttacker.sol";

contract MagicNumberTest is Test {
    address public victim;

    address public txOrigin =
        address(0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38);
    address public attacker = address(new AlienCodexAttacker());

    function setUp() public {
        bytes memory bytecode = abi.encodePacked(
            vm.getCode("AlienCodex.sol:AlienCodex")
        );
        address victimAddr;
        assembly {
            victimAddr := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        victim = victimAddr;
    }

    function testAttack() public {
        vm.startPrank(attacker);

        assertEq(AlienCodex(victim).owner(), address(this));

        AlienCodexAttacker(attacker).attack(victim);

        assertEq(AlienCodex(victim).owner(), txOrigin);
    }
}
