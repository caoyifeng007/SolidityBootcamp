// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./MyERC721Enumerable.sol";

contract PrimeCounter {
    MyEnumerableNFT private immutable _erc721;

    constructor(address erc721) {
        require(erc721 != address(0), "Invalid NFT address");
        _erc721 = MyEnumerableNFT(erc721);
    }

    function countPrimeTokenNum(
        address owner
    ) external view returns (uint256 num) {
        uint256 tokenCounts = _erc721.balanceOf(owner);

        for (uint256 i = 0; i < tokenCounts; ) {
            uint256 tokenId = _erc721.tokenOfOwnerByIndex(owner, i);

            if (_isPrime(tokenId)) {
                unchecked {
                    num++;
                }
            }

            unchecked {
                i++;
            }
        }
    }

    function _isPrime(uint256 n) private pure returns (bool) {
        if (n < 2) return false;
        if (n == 2) return true;
        if (n % 2 == 0) return false;

        for (uint256 i = 3; i * i <= n; ) {
            if (n % i == 0) return false;
            unchecked {
                i += 2;
            }
        }
        return true;
    }
}
