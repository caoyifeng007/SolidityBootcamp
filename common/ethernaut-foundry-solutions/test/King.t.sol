// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";

import {King} from "ethernaut/levels/King.sol";
import {KingAttacker} from "../src/King/KingAttacker.sol";

contract KingTest is Test {
    King public victim;
    KingAttacker public attackerContract;

    address public owner = address(0x3000);
    address public attacker = address(0x2000);

    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.deal(attacker, 10 ether);

        vm.prank(owner);
        victim = new King{value: 1 ether}();

        vm.prank(attacker);
        attackerContract = new KingAttacker{value: 1 ether}(address(victim));
    }

    function testAttack() external {
        vm.startPrank(owner);
        vm.expectRevert(KingAttacker.DosError.selector);
        payable(victim).call{value: 0}("");
    }
}
