// SPDX-License-Identifier: MIT
// pragma solidity ^0.6.0;
pragma solidity ^0.8.13;

/**
 * Original Token is compiled under 0.6.0
 * I put all the code in `unchecked` to simulate 0.6.0
 * So that this puzzle can be run in foundry
 */
contract Token {
    mapping(address => uint) balances;
    uint public totalSupply;

    constructor(uint _initialSupply) public {
        balances[msg.sender] = totalSupply = _initialSupply;
    }

    function transfer(address _to, uint _value) public returns (bool) {
        unchecked {
            require(balances[msg.sender] - _value >= 0);
            balances[msg.sender] -= _value;
            balances[_to] += _value;
        }
        return true;
    }

    function balanceOf(address _owner) public view returns (uint balance) {
        return balances[_owner];
    }
}
