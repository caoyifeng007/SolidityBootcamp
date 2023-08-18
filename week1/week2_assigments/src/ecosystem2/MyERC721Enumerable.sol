// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract MyEnumerableNFT is ERC721Enumerable {
    uint256 private _currentTokenId;

    constructor() ERC721("MyEnumerableNFT", "ENUT") {}

    function mint() external {
        require(_currentTokenId < 20, "Maximum tokens.");
        _currentTokenId++;

        _safeMint(msg.sender, _currentTokenId);
    }
}
