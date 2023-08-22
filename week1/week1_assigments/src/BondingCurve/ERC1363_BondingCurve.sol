// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC1363, ERC20} from "erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol";
import {IERC1363Receiver} from "erc1363-payable-token/contracts/token/ERC1363/IERC1363Receiver.sol";
import {PullPayment} from "@openzeppelin/contracts/security/PullPayment.sol";
import {LinearBondingCurve} from "./LinearBondingCurve.sol";
import {ValidGasPrice} from "./ValidGasPrice.sol";

contract ERC1363BondingCurveToken is
    ERC1363,
    LinearBondingCurve,
    PullPayment,
    ValidGasPrice,
    IERC1363Receiver
{
    uint256 internal _reserveBalance;

    /**
     * Initialise bonding curve at point where supply is 1 token, reserve balance is 0.5 ETH
     * So the curve we used will be : y = x
     */
    constructor() ERC20("BondingCurveToken", "BCT") {
        _reserveBalance = 0.5 ether;
        _mint(msg.sender, 1 * 10 ** decimals());
    }

    /**
     * Users can buy tokens for themselves by sending ETH directly to this contract.
     */
    receive() external payable {
        _buy(msg.sender, msg.value);
    }

    function _buy(address buyer, uint256 amount) internal validGasPrice {
        require(amount > 0, "Deposit must be non-zero.");

        uint256 tokenReward = calculatePurchaseReturn(
            totalSupply(),
            _reserveBalance,
            0,
            amount
        );

        _mint(buyer, tokenReward);
        _reserveBalance += amount;
    }

    /**
     * Users can also buy tokens for thmeselves or other users
     *   by calling this function with different `buyer` address.
     */

    function buy(address buyer) external payable {
        _buy(buyer, msg.value);
    }

    function _sell(
        address tokenOwner,
        uint256 amount,
        address payee
    ) internal validGasPrice {
        require(amount > 0, "Amount must be non-zero.");

        uint256 refundAmount = calculateSaleReturn(
            totalSupply(),
            _reserveBalance,
            0,
            amount
        );
        _burn(tokenOwner, amount);
        _reserveBalance -= refundAmount;

        _asyncTransfer(payee, refundAmount);
    }

    /**
     * Users can sell their own tokens by calling this function directly.
     */
    function sell(uint256 amount) external {
        require(balanceOf(msg.sender) >= amount, "Not enough tokens to sell.");

        _sell(msg.sender, amount, msg.sender);
    }

    /**
     * Users can sell their allwance tokens by calling this function.
     * User can also specify who can receive the benefit
     */
    function sell(address tokenOwner, uint256 amount, address payee) external {
        require(
            allowance(tokenOwner, msg.sender) >= amount,
            "Not enough tokens to sell."
        );

        _sell(tokenOwner, amount, payee);
    }

    /**
     * Users can also sell their own tokens by transferring tokens to this contract
     *  through `transferAndCall`
     *
     * Users can also sell other users' tokens by transferring tokens to this contract
     *  through `transferFromAndCall` while they have approval
     *
     * This function is called after transfer()
     * So when onTransferReceived() is executed:
     *    balanceOf(from) = balanceOf(from) - amount
     *    balanceOf(address(this)) = balanceOf(address(this)) + amount
     */
    function onTransferReceived(
        address operator,
        address from,
        uint256 value,
        bytes calldata
    ) external returns (bytes4) {
        _sell(address(this), value, operator);

        return IERC1363Receiver.onTransferReceived.selector;
    }

    /**
     * To avoid reentrancy attacks
     * reference: https://docs.openzeppelin.com/contracts/4.x/api/security#PullPayment
     */

    function withdrawRefund() external {
        require(
            payments(msg.sender) > 0,
            "You don't have any balance to withdraw."
        );

        withdrawPayments(payable(msg.sender));
    }
}
