// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import {GodToken} from "../src/ERC20_God.sol";

contract GodTokenTest is Test {
    using stdStorage for StdStorage;

    GodToken public token;

    function setUp() public {
        token = new GodToken();
    }

    function testOwnerMintAndBurnForAnyone() public {
        token.mint(address(666), 10);

        token.burn(address(666), 8);
    }

    function testUserMintAndBurnForThemselves() public {
        vm.startPrank(address(888));

        token.mint(address(888), 10);

        token.burn(address(888), 8);

        vm.stopPrank();
    }

    function testRevertWhenUserMintForOthers() public {
        vm.startPrank(address(888));

        vm.expectRevert("Can't mint for others.");
        token.mint(address(666), 10);
    }

    function testRevertWhenUserBurnForOthers() public {
        vm.prank(address(888));
        token.mint(address(888), 10);

        vm.startPrank(address(666));

        vm.expectRevert("Can't burn for others.");
        token.burn(address(888), 10);
    }

    function testOwnerTransferToken() public {
        vm.prank(address(1));
        token.mint(address(1), 10);

        vm.prank(address(2));
        token.mint(address(2), 5);

        vm.startPrank(address(this));

        token.transferByGod(address(1), address(2), 3);
    }

    function testRevertWhenUserTransferToken() public {
        token.mint(address(1), 10);
        token.mint(address(2), 10);

        vm.prank(address(666));

        vm.expectRevert("Ownable: caller is not the owner");
        token.transferByGod(address(1), address(2), 3);
    }
}
