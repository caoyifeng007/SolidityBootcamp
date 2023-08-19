// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract RewardERC20Token is ERC20, Ownable2Step {
    constructor() ERC20("RewardToken", "RTK") {}

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
