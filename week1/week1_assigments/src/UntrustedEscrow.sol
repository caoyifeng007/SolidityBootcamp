// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract UntrustedEscrow {
    using SafeERC20 for IERC20;

    struct Transaction {
        address tokenAddr;
        address buyer;
        address seller;
        uint256 amount;
        uint256 time;
    }

    event Deposited(
        address indexed tokenAddr,
        address indexed buyer,
        address indexed seller,
        uint256 weiAmount
    );

    event Withdrawn(
        address indexed tokenAddr,
        address indexed buyer,
        address indexed seller,
        uint256 weiAmount
    );

    mapping(address => mapping(address => Transaction))
        private _buyerSellerToTx;

    /**
     * buyer needs to specify which ERC20 token he wants to use
     * and a seller he wants to trade with
     */
    function deposit(
        address tokenAddr,
        address seller,
        uint256 amount
    ) external {
        require(tokenAddr != address(0), "Invalid address.");
        require(seller != address(0), "Invalid address.");
        require(amount != 0, "Invalid amount.");
        require(seller != msg.sender, "Can't deposit for yourself.");
        require(
            IERC20(tokenAddr).balanceOf(msg.sender) >= amount,
            "Not enough token."
        );

        require(
            _buyerSellerToTx[msg.sender][seller].amount == 0,
            "Can't deposit before seller withdraw."
        );

        _buyerSellerToTx[msg.sender][seller] = Transaction({
            tokenAddr: tokenAddr,
            buyer: msg.sender,
            seller: seller,
            amount: amount,
            time: block.timestamp
        });
        IERC20(tokenAddr).safeTransferFrom(msg.sender, address(this), amount);

        emit Deposited(address(tokenAddr), msg.sender, seller, amount);
    }

    /**
     * seller needs to specify which buyer he wants to trade with
     */
    function withdraw(address buyer) external {
        require(buyer != address(0), "Invalid address.");

        Transaction memory trx = _buyerSellerToTx[buyer][msg.sender];
        require(trx.amount > 0, "Can't withdraw before buyer deposit.");
        require(
            block.timestamp > (trx.time + 3 days),
            "You can't withdraw within three days."
        );

        delete _buyerSellerToTx[buyer][msg.sender];

        IERC20(trx.tokenAddr).safeTransfer(trx.seller, trx.amount);

        emit Withdrawn(
            address(trx.tokenAddr),
            trx.buyer,
            trx.seller,
            trx.amount
        );
    }
}
