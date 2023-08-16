// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract UntrustedEscrow {
    using SafeERC20 for IERC20;

    struct Transaction {
        IERC20 tokenAddr;
        address buyer;
        address seller;
        uint256 amount;
        uint256 time;
    }

    event Deposited(address indexed tokenAddr, address indexed buyer, address indexed seller, uint256 weiAmount);
    event Withdrawn(address indexed tokenAddr, address indexed buyer, address indexed seller, uint256 weiAmount);

    mapping(address => mapping(address => Transaction)) buyerSellerToTx;

    /**
     * buyer needs to specify which ERC20 token he wants to use
     * and a seller he wants to trade with
     */
    function deposit(IERC20 tokenAddr, address seller, uint256 amount) external {
        require(seller != address(0), "Invalid address.");
        require(amount > 0, "Not enough token.");

        require(buyerSellerToTx[msg.sender][seller].amount != 0, "Can't deposit before seller withdraw.");

        buyerSellerToTx[msg.sender][seller] = Transaction({
            tokenAddr: tokenAddr,
            buyer: msg.sender,
            seller: seller,
            amount: amount,
            time: block.timestamp
        });
        tokenAddr.safeTransfer(address(this), amount);

        emit Deposited(address(tokenAddr), msg.sender, seller, amount);
    }

    /**
     * seller needs to specify which buyer he wants to trade with
     */
    function withdraw(address buyer) external {
        require(buyer != address(0), "Invalid address.");

        Transaction memory trx = buyerSellerToTx[buyer][msg.sender];
        require(trx.amount > 0, "Can't withdraw before buyer deposit.");
        require(trx.seller == msg.sender, "You're not permited to withdraw.");
        require(block.timestamp > (trx.time + 3 days));

        delete buyerSellerToTx[buyer][msg.sender];

        trx.tokenAddr.safeTransfer(trx.seller, trx.amount);

        emit Withdrawn(address(trx.tokenAddr), trx.buyer, trx.seller, trx.amount);
    }
}
