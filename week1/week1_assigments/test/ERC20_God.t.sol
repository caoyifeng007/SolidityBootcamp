// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "../src/ERC20_God.sol";

contract GodTokenTest is Test {
    using stdStorage for StdStorage;

    GodToken public token;

    function setUp() public {
        token = new GodToken();
    }

    function testTransferByGod() public {
        vm.prank(address(1));
        token.mint(address(1), 10);

        vm.prank(address(2));
        token.mint(address(2), 5);

        vm.startPrank(address(this));

        token.transferByGod(address(1), address(2), 3);
    }
}
