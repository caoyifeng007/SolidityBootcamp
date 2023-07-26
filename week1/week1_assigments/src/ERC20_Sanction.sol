// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SanctionToken is ERC20, Ownable {
    mapping(address => bool) private _blackList;

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
        require(_addr != address(0), "Invalid address");
        require(_blackList[_addr] != _flag, "Already updated.");
        _blackList[_addr] = _flag;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        require(!_blackList[from], "Banned address");
        require(!_blackList[to], "Banned address");

        super._beforeTokenTransfer(from, to, amount);
    }
}
