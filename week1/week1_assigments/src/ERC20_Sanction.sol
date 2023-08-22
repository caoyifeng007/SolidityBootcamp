// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

contract SanctionToken is ERC20, Ownable2Step {
    mapping(address => bool) public blackList;

    constructor() ERC20("SanctionToken", "ST") {}

    function mint(address account, uint256 amount) external {
        require(
            msg.sender == owner() || msg.sender == account,
            "Can't mint for others."
        );
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external {
        require(
            msg.sender == owner() || msg.sender == account,
            "Can't burn for others."
        );
        _burn(account, amount);
    }

    function updateBlackList(address _addr, bool _flag) external onlyOwner {
        require(_addr != address(0), "Invalid address.");
        require(blackList[_addr] != _flag, "Already updated.");
        blackList[_addr] = _flag;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(!blackList[from], "Banned address.");
        require(!blackList[to], "Banned address.");

        super._beforeTokenTransfer(from, to, amount);
    }
}
