// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "./RewardERC20.sol";

contract StakeNFT is IERC721Receiver {
    // using SafeERC20 for IERC20;

    RewardERC20Token private erc20;
    mapping(address => uint256) private _lastDeposit;
    // nft address => tokenId => owner
    mapping(address => mapping(uint256 => address)) private _originalOwner;

    constructor() {
        erc20 = new RewardERC20Token();
    }

    function onERC721Received(
        address,
        address from,
        uint256 tokenId,
        bytes calldata
    ) external returns (bytes4) {
        if (block.timestamp > _lastDeposit[from] + 24 hours) {
            uint256 _amount = 10 * 10 ** erc20.decimals();
            erc20.mint(from, _amount);

            _lastDeposit[from] = block.timestamp;

            // Here, msg.sender will be the NFT contract.
            _originalOwner[msg.sender][tokenId] = from;
        }
        return IERC721Receiver.onERC721Received.selector;
    }

    /**
     *
     * @param nft User need to specify which nft he wants to withdraw
     * @param tokenId And specify the tokenId
     */
    function withdrawNFT(address nft, uint256 tokenId) external {
        require(
            _originalOwner[nft][tokenId] == msg.sender,
            "You're not allowed to withdraw."
        );

        delete _originalOwner[nft][tokenId];
        IERC721(nft).safeTransferFrom(address(this), msg.sender, tokenId);
    }
}
