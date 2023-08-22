// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import {ERC1363BondingCurveToken} from "../src/BondingCurve/ERC1363_BondingCurve.sol";

contract ERC1363BondingCurveTokenHarness is ERC1363BondingCurveToken {
    function exposedInnerBuy(address buyer, uint256 amount) external payable {
        return _buy(buyer, amount);
    }

    function exposedInnerSell(
        address seller,
        uint256 amount,
        address payee
    ) external {
        return _sell(seller, amount, payee);
    }
}

contract ERC1363BondingCurveTokenTest is Test {
    using stdStorage for StdStorage;

    ERC1363BondingCurveTokenHarness public token;
    uint256 public TOKEN_INITIAL_SUPPLY;

    address public constant alice = address(1);
    address public constant bob = address(2);
    address public constant carlos = address(3);

    function setUp() public {
        vm.deal(alice, 20 ether);
        vm.deal(bob, 20 ether);

        token = new ERC1363BondingCurveTokenHarness();

        TOKEN_INITIAL_SUPPLY = 1 * 10 ** token.decimals();
    }

    function testContractInitailize() public {
        assertEq(token.balanceOf(address(this)), TOKEN_INITIAL_SUPPLY);
        assertEq(token.totalSupply(), TOKEN_INITIAL_SUPPLY);
    }

    function testRevertWhenHighGasfee() public {
        vm.txGasPrice(2e18);
        vm.expectRevert(
            "Gas price must be <= maximum gas price to prevent front running attacks."
        );
        token.exposedInnerBuy{value: 1.5 ether}(alice, 1e18);
    }

    function testReceive() public {
        // Anyone can just send ETH to ERC1363BondingCurveToken to buy tokens for themselves

        (bool success, ) = address(token).call{value: 1.5 ether}("");
        require(success, "Transfer failed.");

        assertApproxEqAbs(
            token.balanceOf(address(this)),
            TOKEN_INITIAL_SUPPLY + 1e18,
            5
        );

        vm.prank(alice);
        (success, ) = address(token).call{value: 2.5 ether}("");
        require(success, "Transfer failed.");

        assertApproxEqAbs(token.balanceOf(alice), 1e18, 5);
    }

    function testRevertWhenSendZeroValue() public {
        vm.expectRevert("Deposit must be non-zero.");
        (bool success, ) = address(token).call{value: 0 ether}("");
        require(success, "Transfer failed.");
    }

    function testBuy() public {
        // Anyone can call this function to buy token for themselves or others
        vm.startPrank(alice);

        token.buy{value: 1.5 ether}(alice);
        assertApproxEqAbs(token.balanceOf(alice), 1e18, 5);

        token.buy{value: 2.5 ether}(bob);
        assertApproxEqAbs(token.balanceOf(bob), 1e18, 5);
    }

    function testSell() public {
        // Anyone can call `sell(uint256)` to sell their token
        vm.startPrank(alice);

        token.buy{value: 1.5 ether}(alice);
        assertApproxEqAbs(token.balanceOf(alice), 1e18, 5);
        assertApproxEqAbs(alice.balance, 18.5 ether, 5);

        token.sell(token.balanceOf(alice));
        token.withdrawRefund();
        assertApproxEqAbs(token.balanceOf(alice), 0, 5);
        assertApproxEqAbs(alice.balance, 20 ether, 5);
    }

    function testRevertNotEnoughToken() public {
        vm.startPrank(alice);

        // token.buy{value: 4 ether}(alice);
        // assertApproxEqAbs(token.balanceOf(alice), 2e18, 5);

        vm.expectRevert("Not enough tokens to sell.");
        token.sell(5);
    }

    function testSell2() public {
        // User can call `sell(address,uint256,address)` to sell others' token
        vm.startPrank(alice);

        token.buy{value: 4 ether}(alice);
        assertApproxEqAbs(token.balanceOf(alice), 2e18, 5);

        token.approve(bob, 2e18);

        vm.startPrank(bob);
        // Bob sell Alice's token, Bob receives ETH
        token.sell(alice, 1e18, bob);
        token.withdrawRefund();

        assertApproxEqAbs(token.balanceOf(alice), 1e18, 5);
        assertApproxEqAbs(bob.balance, 22.5 ether, 5);

        // Bob sell Alice's token, Alice receives ETH
        token.sell(alice, 1e18, alice);

        vm.startPrank(alice);
        token.withdrawRefund();

        assertApproxEqAbs(token.balanceOf(alice), 0, 5);
        assertApproxEqAbs(alice.balance, 17.5 ether, 5);
    }

    function testRevertWhenNotEnoughAllowance() public {
        vm.startPrank(alice);

        vm.expectRevert("Not enough tokens to sell.");
        token.sell(bob, 10, alice);
    }

    function testRevertWithZeroAmount() public {
        vm.startPrank(alice);

        token.buy{value: 4 ether}(alice);
        assertApproxEqAbs(token.balanceOf(alice), 2e18, 5);

        vm.expectRevert("Amount must be non-zero.");
        token.exposedInnerSell(alice, 0, alice);
    }

    function testSellByTransferTokensBackToERC1363BondingCurve() public {
        vm.startPrank(alice);

        token.buy{value: 4 ether}(alice);
        assertApproxEqAbs(token.balanceOf(alice), 2e18, 5);

        // Alice transfer token, so Alice get the ETH
        token.transferAndCall(address(token), 1e18);
        assertApproxEqAbs(token.balanceOf(alice), 1e18, 5);

        token.withdrawRefund();
        assertApproxEqAbs(alice.balance, 18.5 ether, 5);
    }

    function testSellByTransferTokensBackToERC1363BondingCurve2() public {
        vm.startPrank(alice);

        token.buy{value: 4 ether}(alice);
        assertApproxEqAbs(token.balanceOf(alice), 2e18, 5);

        token.approve(bob, 1e18);

        vm.startPrank(bob);
        // Alice transfer token, so Alice get the ETH
        token.transferFromAndCall(alice, address(token), 1e18);
        assertApproxEqAbs(token.balanceOf(alice), 1e18, 5);

        token.withdrawRefund();
        assertApproxEqAbs(bob.balance, 22.5 ether, 5);
    }

    function testRevertWhenNoETHToWithdraw() public {
        vm.startPrank(alice);

        vm.expectRevert("You don't have any balance to withdraw.");
        token.withdrawRefund();
    }
}
