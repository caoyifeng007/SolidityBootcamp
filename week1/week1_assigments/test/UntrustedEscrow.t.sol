// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {UntrustedEscrow} from "../src/UntrustedEscrow.sol";
import {GodToken} from "../src/ERC20_God.sol";
import {SanctionToken} from "../src/ERC20_Sanction.sol";

contract UntrustedEscrowTest is Test {
    using stdStorage for StdStorage;

    UntrustedEscrow public escrow;
    GodToken public godToken;
    SanctionToken public sanctionToken;

    address public constant alice = address(1);
    address public constant bob = address(2);
    address public constant carlos = address(3);

    function setUp() public {
        escrow = new UntrustedEscrow();
        godToken = new GodToken();
        sanctionToken = new SanctionToken();

        godToken.mint(alice, 1e18);
        sanctionToken.mint(bob, 1e18);
    }

    function testRevertWhenInvalidTokenAddress() public {
        vm.startPrank(alice);

        vm.expectRevert("Invalid address.");
        escrow.deposit(address(0), bob, 1e18);
    }

    function testRevertWhenInvalidSellerAddress() public {
        vm.startPrank(alice);

        vm.expectRevert("Invalid address.");
        escrow.deposit(address(godToken), address(0), 1e18);
    }

    function testRevertWhenInvalidAmount() public {
        vm.startPrank(alice);

        vm.expectRevert("Invalid amount.");
        escrow.deposit(address(godToken), alice, 0);
    }

    function testRevertWhenDepositForSelf() public {
        vm.prank(alice);

        vm.expectRevert("Can't deposit for yourself.");
        escrow.deposit(address(godToken), alice, 20);
    }

    function testRevertWhenInvalidBalance() public {
        vm.prank(alice);

        // Alice has no token in Sanction token
        vm.expectRevert("Not enough token.");
        escrow.deposit(address(sanctionToken), bob, 10);
    }

    function testRevertBeforeSellerWithdraw() public {
        vm.startPrank(alice);

        godToken.approve(address(escrow), 20);
        escrow.deposit(address(godToken), bob, 10);

        vm.expectRevert("Can't deposit before seller withdraw.");
        escrow.deposit(address(godToken), bob, 10);
    }

    function testRevertWithZeroAddress() public {
        vm.startPrank(alice);

        godToken.approve(address(escrow), 20);
        escrow.deposit(address(godToken), bob, 10);

        vm.startPrank(bob);
        vm.expectRevert("Invalid address.");
        escrow.withdraw(address(0));
    }

    function testRevertWithdrawBeforeDeposit() public {
        vm.startPrank(bob);

        vm.expectRevert("Can't withdraw before buyer deposit.");
        escrow.withdraw(alice);
    }

    function testRevertWithdrawWithinThreedays() public {
        vm.startPrank(alice);

        godToken.approve(address(escrow), 20);
        escrow.deposit(address(godToken), bob, 10);

        vm.startPrank(bob);
        vm.expectRevert("You can't withdraw within three days.");
        escrow.withdraw(alice);
    }

    function testDeposit() public {
        vm.startPrank(alice);

        godToken.approve(address(escrow), 1e18);

        escrow.deposit(address(godToken), bob, 5e17);
        assertEq(godToken.balanceOf(alice), 5e17);
        assertEq(godToken.balanceOf(address(escrow)), 5e17);
        assertEq(godToken.balanceOf(bob), 0);

        skip(3 days + 1);
        vm.startPrank(bob);
        escrow.withdraw(alice);

        assertEq(godToken.balanceOf(alice), 5e17);
        assertEq(godToken.balanceOf(address(escrow)), 0);
        assertEq(godToken.balanceOf(bob), 5e17);
    }
}
