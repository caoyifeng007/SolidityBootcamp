// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ERC721RoyaltyUpgradeable} from
    "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721RoyaltyUpgradeable.sol";
import {MerkleProofUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/cryptography/MerkleProofUpgradeable.sol";
import {BitMapsUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/structs/BitMapsUpgradeable.sol";
import {Ownable2StepUpgradeable} from "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract MyUpgradeableNFT is Initializable, ERC721RoyaltyUpgradeable, Ownable2StepUpgradeable, UUPSUpgradeable {
    using BitMapsUpgradeable for BitMapsUpgradeable.BitMap;

    uint256 public constant PRICE = 0.001 ether;
    uint256 public constant DISCOUNTPRICE = 0.0005 ether;

    uint256 private _currentSupply;
    bytes32 private _merkleRoot;
    BitMapsUpgradeable.BitMap private _presaleTicketRecord;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(bytes32 merkleRoot) public initializer {
        __ERC721_init("MyToken", "MTK");
        __Ownable_init();
        __UUPSUpgradeable_init();

        _setDefaultRoyalty(owner(), 250); // 2.5% royalty fee
        _merkleRoot = merkleRoot;
    }

    function _authorizeUpgrade(address newImplementation) internal virtual override onlyOwner {}

    function updateMerkleRoot(bytes32 newRoot) external onlyOwner {
        _merkleRoot = newRoot;
    }

    function _isClaimed(uint256 ticketNum) internal view returns (bool) {
        return _presaleTicketRecord.get(ticketNum);
    }

    function _setClaim(uint256 ticketNum) internal {
        _presaleTicketRecord.set(ticketNum);
    }

    function presaleMint(address to, uint256 ticketNum, uint256 tokneId, bytes32[] calldata merkleProof)
        external
        payable
    {
        require(_currentSupply < 20, "Maximum supply.");
        require(msg.value == DISCOUNTPRICE, "Not enought ETH.");

        require(!_isClaimed(ticketNum), "Ticket has been used.");

        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(to, ticketNum, tokneId));
        require(MerkleProofUpgradeable.verify(merkleProof, _merkleRoot, node), "Invalid proof");

        _currentSupply++;
        _setClaim(ticketNum);
        _safeMint(to, tokneId);
    }

    function mint(address to, uint256 tokenId) external payable {
        require(_currentSupply < 20, "Maximum supply.");
        require(msg.value == PRICE, "Not enought ETH.");

        _currentSupply++;
        _safeMint(to, tokenId);
    }

    function royaltyInfo(uint256 tokenId, uint256 salePrice) public view override returns (address, uint256) {
        require(_exists(tokenId), "Token do not exist.");

        return super.royaltyInfo(tokenId, salePrice);
    }

    function withdraw() external onlyOwner {
        (bool success,) = owner().call{value: address(this).balance}("");
        require(success);
    }
}
