// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import {Ownable2StepUpgradeable} from "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {IERC721ReceiverUpgradeable} from
    "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";

import {RewardERC20Token} from "./RewardERC20.sol";

contract StakeNFT is Initializable, Ownable2StepUpgradeable, UUPSUpgradeable, IERC721ReceiverUpgradeable {
    RewardERC20Token private _erc20;
    mapping(address => uint256) private _lastDeposit;

    // nft address => tokenId => owner
    mapping(address => mapping(uint256 => address)) private _originalOwner;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() external initializer {
        _erc20 = new RewardERC20Token();
        __Ownable2Step_init();
        __UUPSUpgradeable_init();
    }

    function onERC721Received(address, address from, uint256 tokenId, bytes calldata) external returns (bytes4) {
        // Consensys referce : https://consensys.github.io/smart-contract-best-practices/development-recommendations/solidity-specific/timestamp-dependence/#the-15-second-rule
        // Here, 24 hours is much longer than 15 seconds.
        if (block.timestamp > _lastDeposit[from] + 24 hours) {
            _lastDeposit[from] = block.timestamp;

            // Here, msg.sender will be the NFT contract.
            _originalOwner[msg.sender][tokenId] = from;

            uint256 _amount = 10 * 10 ** _erc20.decimals();
            _erc20.mint(from, _amount);
        }
        return IERC721ReceiverUpgradeable.onERC721Received.selector;
    }

    /**
     *
     * @param nft User need to specify which nft he wants to withdraw
     * @param tokenId And specify the tokenId
     */
    function withdrawNFT(address nft, uint256 tokenId) external {
        require(_originalOwner[nft][tokenId] == msg.sender, "You're not allowed to withdraw.");

        delete _originalOwner[nft][tokenId];
        IERC721Upgradeable(nft).safeTransferFrom(address(this), msg.sender, tokenId);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
