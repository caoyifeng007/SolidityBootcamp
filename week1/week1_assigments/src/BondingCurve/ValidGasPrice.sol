// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

contract ValidGasPrice is Ownable {
    uint256 public maxGasPrice = 1 * 10 ** 18;

    // gas price limit prevents users from having control over the order of execution
    modifier validGasPrice() {
        require(tx.gasprice <= maxGasPrice, "Gas price must be <= maximum gas price to prevent front running attacks.");
        _;
    }

    function setMaxGasPrice(uint256 newPrice) public onlyOwner {
        maxGasPrice = newPrice;
    }
}
