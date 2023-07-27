// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GodToken is ERC20, Ownable {
    constructor() ERC20("GodToken", "GT") {}

    function mint(address account, uint256 amount) external {
        require(msg.sender == owner() || msg.sender == account, "Can't mint for others.");
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external {
        require(msg.sender == owner() || msg.sender == account, "Can't burn for others.");
        _burn(account, amount);
    }

    function transferByGod(address _from, address _to, uint256 _amount) external onlyOwner returns (bool) {
        _transfer(_from, _to, _amount);
        return true;
    }
}
