// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

// import {MagicNum} from "ethernaut/levels/MagicNum.sol";
import {YulDeployer} from "../test/utils/yul/YulDeployer.t.sol";

interface Attacker {
    function whatIsTheMeaningOfLife() external returns (bytes32);
}

contract MagicNumberTest is Test {
    YulDeployer yulDeployer = new YulDeployer();

    bytes32 magic =
        0x000000000000000000000000000000000000000000000000000000000000002a;

    address attacker;

    function setUp() public {
        attacker = yulDeployer.deployContract("src/MagicNumber/Attacker.yul");
    }

    function testAttack() public {
        address attackerAddr = attacker;

        uint256 size;
        assembly {
            size := extcodesize(attackerAddr)
        }

        assertTrue(size <= 10);

        assertEq(Attacker(attackerAddr).whatIsTheMeaningOfLife(), magic);
    }
}
