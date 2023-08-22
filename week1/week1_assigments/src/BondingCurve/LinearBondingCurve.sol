// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol";

import {UD60x18, ud, unwrap, powu, sqrt, add, sub} from "prb-math/UD60x18.sol";

/**
 * The purchase and sell formula equations come from Bancor Formula
 * https://drive.google.com/file/d/0B3HPNP-GDn7aRkVaV3dkVl9NS2M/view?resourcekey=0-mbIgrdd0B9H8dPNRaeB_TA
 *
 * Set reserve ratio (i.e. F in Bancor Formula) to 1/2
 */
contract LinearBondingCurve {
    /**
     * Purchase equation: T = S0 * ((1 + E / R0) ^ F - 1)
     * This equation calculate how many tokens we get if we spend E ETH
     *
     * In code:
     *    Return = _supply * ((1 + _depositAmout / _reserveBalance) ^ 1/2 - 1 )
     */

    function calculatePurchaseReturn(
        uint256 _supply,
        uint256 _reserveBalance,
        uint32,
        uint256 _depositAmount
    ) public pure returns (uint256) {
        UD60x18 s = ud(_supply);
        UD60x18 r = ud(_reserveBalance);
        UD60x18 d = ud(_depositAmount);

        UD60x18 x1 = ud(1e18).add(d.div(r));
        UD60x18 x2 = (x1.sqrt()).sub(ud(1e18));
        UD60x18 ret = s.mul(x2);

        return unwrap(ret);
    }

    /**
     * Origin equation is: E = R0 * ((1 + T / S0) ^ (1 / F) - 1)
     * But this equation only calculate how much ETH we spend if we mint tokens from S0 to (S0 + T)
     *
     * After transforming the equation we get
     * Sale equation: E = R0 * (1 - (1 - (T / S0) ^ (1 / F))
     * This euqation calculate how much ETH we get if we sell tokens from S0 to (S0 - T)
     *
     * In code:
     *    Return = _reserveBalance * (1 - (1 - _sellAmount / _supply) ^ 2 )
     */
    function calculateSaleReturn(
        uint256 _supply,
        uint256 _reserveBalance,
        uint32,
        uint256 _sellAmount
    ) public pure returns (uint256) {
        UD60x18 su = ud(_supply);
        UD60x18 r = ud(_reserveBalance);
        UD60x18 sm = ud(_sellAmount);

        UD60x18 x1 = ud(1e18).sub(sm.div(su));
        UD60x18 x2 = ud(1e18).sub(x1.powu(2));
        UD60x18 ret = r.mul(x2);

        return unwrap(ret);
    }
}
