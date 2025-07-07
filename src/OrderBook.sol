// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 *  ░▒▓██████▓▒░░▒▓███████▓▒░░▒▓███████▓▒░░▒▓████████▓▒░▒▓███████▓▒░       ░▒▓███████▓▒░ ░▒▓██████▓▒░ ░▒▓██████▓▒░░▒▓█▓▒░░▒▓█▓▒░
 * ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░
 * ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░
 * ░▒▓█▓▒░░▒▓█▓▒░▒▓███████▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓██████▓▒░ ░▒▓███████▓▒░       ░▒▓███████▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓███████▓▒░
 * ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░
 * ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░
 *  ░▒▓██████▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓███████▓▒░░▒▓████████▓▒░▒▓█▓▒░░▒▓█▓▒░      ░▒▓███████▓▒░ ░▒▓██████▓▒░ ░▒▓██████▓▒░░▒▓█▓▒░░▒▓█▓▒░
 */
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol"; // For number to string conversion

/**
 * @title OrderBook
 * @author Chukwubuike Victory Chime yeahChibyke @github.com
 * @notice This contract is built to mirror the way order-books operate in TradFi, but on DeFi, as close as possible
 */
contract OrderBook is Ownable {
    using SafeERC20 for IERC20;
    using Strings for uint256;

    struct Order {
        uint256 id;
        address seller;
        address tokenToSell; // Address of wETH, wBTC, or wSOL
        uint256 amountToSell; // Amount of tokenToSell
        uint256 priceInUSDC; // Total USDC price for the entire amountToSell
        uint256 deadlineTimestamp; // Block timestamp after which the order expires
        bool isActive; // Flag indicating if the order is available to be bought
    }

    // --- Constants ---
    uint256 public constant MAX_DEADLINE_DURATION = 3 days; // Max duration from now for a deadline
    uint256 public constant FEE = 3; // 3%
    uint256 public constant PRECISION = 100;

    // --- State Variables ---
    IERC20 public immutable iWETH;
    IERC20 public immutable iWBTC;
    IERC20 public immutable iWSOL;
    IERC20 public immutable iUSDC;

    mapping(address => bool) public allowedSellToken;

    mapping(uint256 => Order) public orders;
    uint256 private _nextOrderId;
    uint256 public totalFees;

    // --- Events ---
    event OrderCreated(
        uint256 indexed orderId,
        address indexed seller,
        address indexed tokenToSell,
        uint256 amountToSell,
        uint256 priceInUSDC,
        uint256 deadlineTimestamp
    );
    event OrderAmended(
        uint256 indexed orderId, uint256 newAmountToSell, uint256 newPriceInUSDC, uint256 newDeadlineTimestamp
    );
    event OrderCancelled(uint256 indexed orderId, address indexed seller);
    event OrderFilled(uint256 indexed orderId, address indexed buyer, address indexed seller);
    event TokenAllowed(address indexed token, bool indexed status);
    event EmergencyWithdrawal(address indexed token, uint256 indexed amount, address indexed receiver);
    event FeesWithdrawn(address indexed receiver);

    // --- Errors ---
    error OrderNotFound();
    error NotOrderSeller();
    error OrderNotActive();
    error OrderExpired();
    error OrderAlreadyInactive();
    error InvalidToken();
    error InvalidAmount();
    error InvalidPrice();
    error InvalidDeadline();
    error InvalidAddress();

    // --- Constructor ---
    constructor(address _weth, address _wbtc, address _wsol, address _usdc, address _owner) Ownable(_owner) {
        if (_weth == address(0) || _wbtc == address(0) || _wsol == address(0) || _usdc == address(0)) {
            revert InvalidToken();
        }
        if (_owner == address(0)) {
            revert InvalidAddress();
        }

        iWETH = IERC20(_weth);
        allowedSellToken[_weth] = true;

        iWBTC = IERC20(_wbtc);
        allowedSellToken[_wbtc] = true;

        iWSOL = IERC20(_wsol);
        allowedSellToken[_wsol] = true;

        iUSDC = IERC20(_usdc);

        _nextOrderId = 1; // Start order IDs from 1
    }

    function createSellOrder(
        address _tokenToSell,
        uint256 _amountToSell,
        uint256 _priceInUSDC,
        uint256 _deadlineDuration
    ) public returns (uint256) {
        if (!allowedSellToken[_tokenToSell]) revert InvalidToken();
        if (_amountToSell == 0) revert InvalidAmount();
        if (_priceInUSDC == 0) revert InvalidPrice();
        if (_deadlineDuration == 0 || _deadlineDuration > MAX_DEADLINE_DURATION) revert InvalidDeadline();

        uint256 deadlineTimestamp = block.timestamp + _deadlineDuration;
        uint256 orderId = _nextOrderId++;

        //@audit (Medium) CEI pattern: Ensure the order is created only after the token transfer
        IERC20(_tokenToSell).safeTransferFrom(msg.sender, address(this), _amountToSell);

        // Store the order
        orders[orderId] = Order({
            id: orderId,
            seller: msg.sender,
            tokenToSell: _tokenToSell,
            amountToSell: _amountToSell,
            priceInUSDC: _priceInUSDC,
            deadlineTimestamp: deadlineTimestamp,
            isActive: true
        });

        emit OrderCreated(orderId, msg.sender, _tokenToSell, _amountToSell, _priceInUSDC, deadlineTimestamp);
        return orderId;
    }

    function amendSellOrder(
        uint256 _orderId,
        uint256 _newAmountToSell,
        uint256 _newPriceInUSDC,
        uint256 _newDeadlineDuration
    ) public {
        Order storage order = orders[_orderId];

        // Validation checks
        if (order.seller == address(0)) revert OrderNotFound(); // Check if order exists
        if (order.seller != msg.sender) revert NotOrderSeller();
        if (!order.isActive) revert OrderAlreadyInactive();
        if (block.timestamp >= order.deadlineTimestamp) revert OrderExpired(); // Cannot amend expired order
        if (_newAmountToSell == 0) revert InvalidAmount();
        if (_newPriceInUSDC == 0) revert InvalidPrice();
        if (_newDeadlineDuration == 0 || _newDeadlineDuration > MAX_DEADLINE_DURATION) revert InvalidDeadline();

        uint256 newDeadlineTimestamp = block.timestamp + _newDeadlineDuration;
        IERC20 token = IERC20(order.tokenToSell);

        //@audit (Medium) CEI pattern: Update order details before handle token amount change transfers
        //@audit Need to create tests for when _newAmountToSell is Greater and Less than order.amountToSell
        // Handle token amount changes
        if (_newAmountToSell > order.amountToSell) {
            // Increasing amount: Transfer additional tokens from seller
            uint256 diff = _newAmountToSell - order.amountToSell;
            token.safeTransferFrom(msg.sender, address(this), diff);
        } else if (_newAmountToSell < order.amountToSell) {
            // Decreasing amount: Transfer excess tokens back to seller
            uint256 diff = order.amountToSell - _newAmountToSell;
            token.safeTransfer(order.seller, diff);
        }

        // Update order details
        order.amountToSell = _newAmountToSell;
        order.priceInUSDC = _newPriceInUSDC;
        order.deadlineTimestamp = newDeadlineTimestamp;

        emit OrderAmended(_orderId, _newAmountToSell, _newPriceInUSDC, newDeadlineTimestamp);
    }

    function cancelSellOrder(uint256 _orderId) public {
        Order storage order = orders[_orderId];

        // Validation checks
        if (order.seller == address(0)) revert OrderNotFound();
        if (order.seller != msg.sender) revert NotOrderSeller();
        if (!order.isActive) revert OrderAlreadyInactive(); // Already inactive (filled or cancelled)

        // Mark as inactive
        order.isActive = false;

        // Return locked tokens to the seller
        IERC20(order.tokenToSell).safeTransfer(order.seller, order.amountToSell);

        emit OrderCancelled(_orderId, order.seller);
    }

    function buyOrder(uint256 _orderId) public {
        Order storage order = orders[_orderId];

        // Validation checks
        if (order.seller == address(0)) revert OrderNotFound();
        //@audit (low) Missing check for msg.sender can buy own order
        // if (order.seller == msg.sender) revert CannotBuyOwnOrder();
        if (!order.isActive) revert OrderNotActive();
        if (block.timestamp >= order.deadlineTimestamp) revert OrderExpired();

        //@audit (Medium) Fee Calculation Precision
        order.isActive = false;
        uint256 protocolFee = (order.priceInUSDC * FEE) / PRECISION;
        uint256 sellerReceives = order.priceInUSDC - protocolFee;

        iUSDC.safeTransferFrom(msg.sender, address(this), protocolFee);
        iUSDC.safeTransferFrom(msg.sender, order.seller, sellerReceives);
        IERC20(order.tokenToSell).safeTransfer(msg.sender, order.amountToSell);

        //@audit (Medium) CEI pattern: Ensure the order is marked inactive before transferring tokens
        totalFees += protocolFee;

        emit OrderFilled(_orderId, msg.sender, order.seller);
    }

    function getOrder(uint256 _orderId) public view returns (Order memory orderDetails) {
        if (orders[_orderId].seller == address(0)) revert OrderNotFound();
        orderDetails = orders[_orderId];
    }

    function getOrderDetailsString(uint256 _orderId) public view returns (string memory details) {
        Order storage order = orders[_orderId];
        if (order.seller == address(0)) revert OrderNotFound(); // Check if order exists

        string memory tokenSymbol;
        if (order.tokenToSell == address(iWETH)) {
            tokenSymbol = "wETH";
        } else if (order.tokenToSell == address(iWBTC)) {
            tokenSymbol = "wBTC";
        } else if (order.tokenToSell == address(iWSOL)) {
            tokenSymbol = "wSOL";
        }

        string memory status = order.isActive
            ? (block.timestamp < order.deadlineTimestamp ? "Active" : "Expired (Active but past deadline)")
            : "Inactive (Filled/Cancelled)";
        if (order.isActive && block.timestamp >= order.deadlineTimestamp) {
            status = "Expired (Awaiting Cancellation)";
        } else if (!order.isActive) {
            status = "Inactive (Filled/Cancelled)";
        } else {
            status = "Active";
        }

        details = string(
            abi.encodePacked(
                "Order ID: ",
                order.id.toString(),
                "\n",
                "Seller: ",
                Strings.toHexString(uint160(order.seller), 20),
                "\n",
                "Selling: ",
                order.amountToSell.toString(),
                " ",
                tokenSymbol,
                "\n",
                "Asking Price: ",
                order.priceInUSDC.toString(),
                " USDC\n",
                "Deadline Timestamp: ",
                order.deadlineTimestamp.toString(),
                "\n",
                "Status: ",
                status
            )
        );

        return details;
    }

    function setAllowedSellToken(address _token, bool _isAllowed) external onlyOwner {
        if (_token == address(0) || _token == address(iUSDC)) revert InvalidToken(); // Cannot allow null or USDC itself
        allowedSellToken[_token] = _isAllowed;

        emit TokenAllowed(_token, _isAllowed);
    }

    function emergencyWithdrawERC20(address _tokenAddress, uint256 _amount, address _to) external onlyOwner {
        if (
            _tokenAddress == address(iWETH) || _tokenAddress == address(iWBTC) || _tokenAddress == address(iWSOL)
                || _tokenAddress == address(iUSDC)
        ) {
            revert("Cannot withdraw core order book tokens via emergency function");
        }
        if (_to == address(0)) {
            revert InvalidAddress();
        }
        IERC20 token = IERC20(_tokenAddress);
        token.safeTransfer(_to, _amount);

        emit EmergencyWithdrawal(_tokenAddress, _amount, _to);
    }

    function withdrawFees(address _to) external onlyOwner {
        if (totalFees == 0) {
            revert InvalidAmount();
        }
        if (_to == address(0)) {
            revert InvalidAddress();
        }

        iUSDC.safeTransfer(_to, totalFees);

        totalFees = 0;

        emit FeesWithdrawn(_to);
    }
}
