// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./MyERC721Enumerable.sol";

contract PrimeCounter {
    MyEnumerableNFT private erc721;

    constructor(address _erc721) {
        require(_erc721 != address(0), "Invalid NFT address");
        erc721 = MyEnumerableNFT(_erc721);
    }

    function countPrimeTokenNum(
        address _owner
    ) external view returns (uint256 num) {
        uint256 tokenCounts = erc721.balanceOf(_owner);

        for (uint256 i = 0; i < tokenCounts; ) {
            uint256 tokenId = erc721.tokenOfOwnerByIndex(_owner, i);

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
