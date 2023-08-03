// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol";
import "erc1363-payable-token/contracts/token/ERC1363/IERC1363Receiver.sol";
import "@openzeppelin/contracts/security/PullPayment.sol";
import "./LinearBondingCurve.sol";

import "forge-std/Test.sol";

contract BondingCurveToken is Test, ERC1363, LinearBondingCurve, PullPayment, IERC1363Receiver {
    uint256 internal reserveBalance;

    /**
     * Initialise bonding curve at point where supply is 1 token, reserve balance is 0.5 ETH
     * So the curve we used will be : y = x
     */
    constructor() ERC20("BondingCurveToken", "BCT") {
        reserveBalance = 0.5 ether;
        _mint(msg.sender, 1 * 10 ** decimals());
    }

    /**
     * Users can buy tokens for themselves by sending ETH directly to this contract.
     */
    receive() external payable {
        _buy(msg.sender, msg.value);
    }

    function _buy(address buyer, uint256 amount) internal {
        require(amount > 0, "Deposit must be non-zero.");

        uint256 tokenReward = calculatePurchaseReturn(totalSupply(), reserveBalance, 0, amount);
        // console2.log(tokenReward);

        _mint(buyer, tokenReward);
        reserveBalance += amount;
    }

    /**
     * Users can also buy tokens for thmeselves or other users
     *   by calling this function with different `buyer` address.
     */

    function buy(address buyer) external payable {
        _buy(buyer, msg.value);
    }

    function _sell(address seller, uint256 amount, address payee) internal {
        require(amount > 0, "Amount must be non-zero.");

        uint256 refundAmount = calculateSaleReturn(totalSupply(), reserveBalance, 0, amount);
        _burn(seller, amount);
        reserveBalance -= refundAmount;

        _asyncTransfer(payee, refundAmount);
    }

    /**
     * Users can sell their own tokens by calling this function directly.
     */
    function sell(uint256 amount) external {
        _sell(msg.sender, amount, msg.sender);
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
     *    balanceOf(sender) = balanceOf(sender) - amount
     *    balanceOf(address(this)) = balanceOf(address(this)) + amount
     */
    function onTransferReceived(address spender, address sender, uint256 amount, bytes calldata data)
        external
        returns (bytes4)
    {
        _sell(address(this), amount, spender);

        return IERC1363Receiver.onTransferReceived.selector;
    }

    /**
     * To avoid reentrancy attacks
     * reference: https://docs.openzeppelin.com/contracts/4.x/api/security#PullPayment
     */

    function withdrawRefund() external {
        require(payments(msg.sender) > 0, "You don't have any balance to withdraw.");

        withdrawPayments(payable(msg.sender));
    }
}
