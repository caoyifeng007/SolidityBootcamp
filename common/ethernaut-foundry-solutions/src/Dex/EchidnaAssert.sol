// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Dex, SwappableToken} from "ethernaut/levels/Dex.sol";

contract DexEchidnaExploitAssert {
    Dex public dex;
    SwappableToken public token1;
    SwappableToken public token2;

    address public attacker;

    constructor() {
        // attacker = msg.sender;

        dex = new Dex();

        // DexEchidnaExploitAssert is the owner of token1 and token2
        // So DexEchidnaExploitAssert have 110 of each token
        token1 = new SwappableToken(address(dex), "", "", 110);
        token2 = new SwappableToken(address(dex), "", "", 110);
        dex.setTokens(address(token1), address(token2));

        // transfer to dex
        token1.approve(address(dex), 100);
        token2.approve(address(dex), 100);
        dex.addLiquidity(address(token1), 100);
        dex.addLiquidity(address(token2), 100);

        // transfer to attacker
        token1.transfer(address(0x3000), 10);
        token2.transfer(address(0x3000), 10);

        dex.renounceOwnership();
    }

    // function testInitialize() public view {
    //     assert(token1.balanceOf(attacker) == 10);
    //     assert(token2.balanceOf(attacker) == 10);

    //     assert(token1.balanceOf(address(dex)) == 100);
    //     assert(token2.balanceOf(address(dex)) == 100);

    //     assert(dex.token1() == address(token1));
    //     assert(dex.token2() == address(token2));
    // }

    event LogAddr(address);
    event Log(uint256, uint256);

    function exploit(uint256 amount, bool chooseToken) public {
        // require(msg.sender == attacker);
        emit LogAddr(msg.sender);

        uint256 attackerBalance1 = token1.balanceOf(msg.sender);
        uint256 attackerBalance2 = token2.balanceOf(msg.sender);
        uint256 dexBalance1 = token1.balanceOf(address(dex));
        uint256 dexBalance2 = token2.balanceOf(address(dex));

        // attacker approve dex
        dex.approve(address(dex), type(uint256).max);

        emit Log(attackerBalance1, attackerBalance2);
        emit Log(dexBalance1, dexBalance2);
        if (chooseToken) {
            dex.swap(
                address(token2),
                address(token1),
                (amount % attackerBalance2) % dexBalance2
            );
        } else {
            dex.swap(
                address(token1),
                address(token2),
                (amount % attackerBalance1) % dexBalance1
            );
        }

        assert(token1.balanceOf(address(dex)) > 5);
        assert(token2.balanceOf(address(dex)) > 5);

        // assert(
        //     token1.balanceOf(address(dex)) != 0 &&
        //         token2.balanceOf(address(dex)) != 0
        // );
    }
}
