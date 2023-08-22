// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import {SanctionToken} from "../src/ERC20_Sanction.sol";

contract SanctionTokenTest is Test {
    using stdStorage for StdStorage;

    SanctionToken public token;

    function setUp() public {
        token = new SanctionToken();
    }

    function testOwnerMintAndBurnForAnyone() public {
        token.mint(address(1), 10);

        token.burn(address(1), 8);
    }

    function testUserMintForThemselves() public {
        vm.startPrank(address(1));

        token.mint(address(1), 10);
    }

    function testRevertWhenUserMintForOhers() public {
        vm.prank(address(1));

        vm.expectRevert(bytes("Can't mint for others."));
        token.mint(address(2), 10);
    }

    function testRevertWhenUserBurnForOhers() public {
        token.mint(address(2), 10);

        vm.prank(address(1));

        vm.expectRevert(bytes("Can't burn for others."));
        token.burn(address(2), 10);
    }

    function testOwnerUpdateBlackList() public {
        token.updateBlackList(address(2), true);

        token.updateBlackList(address(2), false);
    }

    function testRevertWhenOwnerUpdateZeroAddress() public {
        vm.expectRevert(bytes("Invalid address."));

        token.updateBlackList(address(0), true);
    }

    function testRevertWhenAlreadUpdated() public {
        stdstore
            .target(address(token))
            .sig("blackList(address)")
            .with_key(address(1))
            .checked_write(true);

        vm.expectRevert(bytes("Already updated."));

        token.updateBlackList(address(1), true);
    }

    function testRevertWhenUserUpdateBlackList() public {
        vm.prank(address(1));
        vm.expectRevert(bytes("Ownable: caller is not the owner"));

        token.updateBlackList(address(1), true);
    }

    function testRevertWhenTransferToAddressInBlackList() public {
        token.mint(address(this), 10);
        token.updateBlackList(address(3), true);

        vm.expectRevert(bytes("Banned address."));

        token.transfer(address(3), 5);
    }

    function testRevertWhenTransferFromAddressInBlackList() public {
        token.mint(address(3), 10);
        token.updateBlackList(address(3), true);

        vm.startPrank(address(3));

        vm.expectRevert(bytes("Banned address."));

        token.transfer(address(1), 5);
    }
}
