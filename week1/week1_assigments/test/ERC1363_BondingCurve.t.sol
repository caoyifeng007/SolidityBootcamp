// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "../src/BondingCurve/ERC1363_BondingCurve.sol";

contract GodTokenTest is Test {
    using stdStorage for StdStorage;

    BondingCurveToken public token;
    uint256 public constant INITIALSUPPLY = 1 ether;

    function setUp() public {
        token = new BondingCurveToken();
    }

    function testBuyAndSell() public {
        address alice = address(1);
        address bob = address(2);
        address carlos = address(3);
        vm.deal(alice, 20 ether);
        vm.deal(bob, 20 ether);

        /**
         * Test buy
         */
        vm.startPrank(alice);

        // First way: Alice can buy herself 1 token by sending ETH to contract directly.
        (bool success,) = address(token).call{value: 1.5 ether}("");
        require(success, "Transfer failed.");
        uint256 ONETOKEN = token.balanceOf(alice);
        assertEq(token.totalSupply(), INITIALSUPPLY + ONETOKEN);

        // Second way: Alice can buy herself 1 token by calling `buy` function with her account.
        token.buy{value: 2.5 ether}(alice);
        assertEq(token.balanceOf(alice), 2 * ONETOKEN);
        assertEq(token.totalSupply(), INITIALSUPPLY + 2 * ONETOKEN);

        // Alice can by Bob 1 token by calling `buy` function with Bob's account.
        token.buy{value: 3.5 ether}(bob);
        assertEq(token.balanceOf(bob), ONETOKEN);
        assertEq(token.totalSupply(), INITIALSUPPLY + 3 * ONETOKEN);

        /**
         * Test sell
         */

        // First way: Alice can sell 1 token by calling `sell` function.
        token.sell(ONETOKEN);
        require(success, "Transfer failed.");
        assertEq(token.balanceOf(alice), ONETOKEN);
        assertEq(token.totalSupply(), INITIALSUPPLY + 2 * ONETOKEN);

        // Second way: Alice can sell 1 token by transferring her token back to BondingCurve contract.
        token.transferAndCall(address(token), ONETOKEN);
        assertEq(token.balanceOf(alice), 0);
        assertEq(token.totalSupply(), INITIALSUPPLY + ONETOKEN);

        // Bob approve Carlos can spend 1 token from his account
        vm.prank(bob);
        token.approve(carlos, ONETOKEN);

        // Carlos sell 1 token from Bob's account, and the ETH goes to Carlos's account
        vm.startPrank(carlos);
        token.transferFromAndCall(bob, address(token), ONETOKEN, "");
        assertEq(token.balanceOf(bob), 0);

        token.withdrawRefund();
        assertEq(carlos.balance, 1.5 ether);
        assertEq(token.totalSupply(), INITIALSUPPLY);

        // vm.stopPrank();
    }
}
