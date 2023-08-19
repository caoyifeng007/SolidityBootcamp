// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract MyNFT is ERC721Royalty, Ownable2Step {
    using BitMaps for BitMaps.BitMap;

    uint256 public constant PRICE = 0.001 ether;
    uint256 public constant DISCOUNTPRICE = 0.0005 ether;

    uint256 private _currentSupply;
    bytes32 private merkleRoot;
    BitMaps.BitMap private presaleTicketRecord;

    constructor(bytes32 _merkleRoot) ERC721("MyToken", "MTK") {
        _setDefaultRoyalty(owner(), 250); // 2.5% royalty fee
        merkleRoot = _merkleRoot;
    }

    function updateMerkleRoot(bytes32 _newRoot) external onlyOwner {
        merkleRoot = _newRoot;
    }

    function withdraw() external onlyOwner {
        (bool success, ) = owner().call{value: address(this).balance}("");
        require(success);
    }

    function royaltyInfo(
        uint256 tokenId,
        uint256 salePrice
    ) public view override returns (address, uint256) {
        require(_exists(tokenId), "Token do not exist.");

        return super.royaltyInfo(tokenId, salePrice);
    }

    function _isClaimed(uint256 ticketNum) internal view returns (bool) {
        return presaleTicketRecord.get(ticketNum);
    }

    function _setClaim(uint256 ticketNum) internal {
        presaleTicketRecord.set(ticketNum);
    }

    function presaleMint(
        address to,
        uint256 ticketNum,
        uint256 tokneId,
        bytes32[] calldata merkleProof
    ) external payable {
        require(_currentSupply < 20, "Maximum supply.");
        require(msg.value == DISCOUNTPRICE, "Not enought ETH.");

        require(!_isClaimed(ticketNum), "Ticket has been used.");

        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(to, ticketNum, tokneId));
        require(
            MerkleProof.verify(merkleProof, merkleRoot, node),
            "Invalid proof"
        );

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
}
