// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

import {Privacy} from "ethernaut/levels/Privacy.sol";

contract ShopTest is Test {
    Privacy public victim;
    address public wallet = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    address public attacker = address(0x2000);

    function setUp() public {
        bytes32[3] memory data;
        data[0] = keccak256(abi.encodePacked(wallet, "0"));
        data[1] = keccak256(abi.encodePacked(wallet, "1"));
        data[2] = keccak256(abi.encodePacked(wallet, "2"));
        victim = new Privacy(data);
    }

    function testAttack() external {
        bytes32 key = hex"7c4132911140941f6873d6de6aaf49338f9d8e96290e457f8e061096f66518fe";
        victim.unlock(bytes16(key));

        assertTrue(!victim.locked());
    }
}
