// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol";
import "./IBondingCurve.sol";
import "solidity-math-utils/AnalyticMath.sol";

/**
 * The purchase and sell formula equations come from Bancor Formula
 * https://drive.google.com/file/d/0B3HPNP-GDn7aRkVaV3dkVl9NS2M/view?resourcekey=0-mbIgrdd0B9H8dPNRaeB_TA
 *
 * Set reserve ratio (i.e. F in Bancor Formula) to 1/2
 */
contract LinearBondingCurve is IBondingCurve, AnalyticMath {
    /**
     * Purchase equation: T = S0 * ((1 + E / R0) ^ F - 1)
     * This equation calculate how many tokens we get if we spend E ETH
     *
     * In code:
     *    Return = _supply * ((1 + _depositAmout / _reserveBalance) ^ 1/2 - 1 )
     */

    function calculatePurchaseReturn(uint256 _supply, uint256 _reserveBalance, uint32, uint256 _depositAmount)
        public
        view
        returns (uint256)
    {
        (uint256 n, uint256 d) = pow((_reserveBalance + _depositAmount), _reserveBalance, 1, 2);
        return IntegralMath.mulDivF(_supply, n, d) - _supply;
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
    function calculateSaleReturn(uint256 _supply, uint256 _reserveBalance, uint32, uint256 _sellAmount)
        public
        view
        returns (uint256)
    {
        (uint256 n, uint256 d) = pow(_supply, (_supply - _sellAmount), 2, 1);
        return IntegralMath.mulDivF(_reserveBalance, n - d, n);
    }
}
