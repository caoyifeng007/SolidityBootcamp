// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SanctionToken is ERC20, Ownable {
    mapping(address => bool) public blackList;

    constructor() ERC20("SanctionToken", "ST") {}

    function mint(address account, uint256 amount) external {
        require(msg.sender == owner() || msg.sender == account, "Can't mint for others.");
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external {
        require(msg.sender == owner() || msg.sender == account, "Can't mint for others.");
        _burn(account, amount);
    }

    function updateBlackList(address _addr, bool _flag) external onlyOwner {
        require(_addr != address(0), "Invalid address.");
        require(blackList[_addr] != _flag, "Already updated.");
        blackList[_addr] = _flag;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        require(!blackList[from], "Banned address.");
        require(!blackList[to], "Banned address.");

        super._beforeTokenTransfer(from, to, amount);
    }
}
