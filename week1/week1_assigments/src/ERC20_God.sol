// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

contract GodToken is ERC20, Ownable2Step {
    constructor() ERC20("GodToken", "GT") {}

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

    function transferByGod(
        address _from,
        address _to,
        uint256 _amount
    ) external onlyOwner returns (bool) {
        _transfer(_from, _to, _amount);
        return true;
    }
}
