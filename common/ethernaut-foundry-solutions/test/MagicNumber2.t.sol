// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

interface Attacker {
    function whatIsTheMeaningOfLife() external returns (bytes32);
}

contract MagicNumberTest is Test {
    bytes32 magic =
        0x000000000000000000000000000000000000000000000000000000000000002a;

    address attacker;

    function setUp() public {
        bytes memory bytecode = abi.encodePacked(
            vm.getCode("MagicNumberAttacker.yul:Simple")
        );
        address contractAddr;
        assembly {
            contractAddr := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        attacker = contractAddr;
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
