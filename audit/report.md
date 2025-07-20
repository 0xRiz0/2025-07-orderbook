---
title: Protocol Audit Report
author: 0xRiz0
date: July 8, 2025
header-includes:
  - \usepackage{titling}
  - \usepackage{graphicx}
---

\begin{titlepage}
    \centering
    \begin{figure}[h]
        \centering
        \includegraphics[width=0.5\textwidth]{logo.pdf} 
    \end{figure}
    \vspace*{2cm}
    {\Huge\bfseries Protocol Audit Report\par}
    \vspace{1cm}
    {\Large Version 1.0\par}
    \vspace{2cm}
    {\Large\itshape 0xRiz0\par}
    \vfill
    {\large \today\par}
\end{titlepage}

\maketitle

<!-- Your report starts here! -->

Prepared by: [0xRiz0](https://github.com/0xRiz0)
Lead Auditor(s):
- 0xRiz0

Assisting Auditors:
- None

# Table of Contents
- [Table of Contents](#table-of-contents)
- [Protocol Summary](#protocol-summary)
- [Disclaimer](#disclaimer)
- [Risk Classification](#risk-classification)
- [Audit Details](#audit-details)
  - [Scope](#scope)
  - [Roles](#roles)
- [Executive Summary](#executive-summary)
  - [Issues found](#issues-found)
- [Findings](#findings)
  - [High](#high)
    - [\[H-1\]](#h-1)
  - [Medium](#medium)
    - [\[M-1\]](#m-1)
  - [Low](#low)
    - [\[L-1\]](#l-1)
  - [Informational](#informational)
    - [\[I-1\]](#i-1)
  - [Gas](#gas)
    - [\[G-1\]](#g-1)

# Protocol Summary

The OrderBook contract is a peer-to-peer trading system designed for ERC20 tokens like wETH, wBTC, and wSOL. Sellers can list tokens at their desired price in USDC, and buyers can fill them directly on-chain.

# Disclaimer

The 0xRiz0 team makes all effort to find as many vulnerabilities in the code in the given time period, but holds no responsibilities for the findings provided in this document. A security audit by the team is not an endorsement of the underlying business or product. The audit was time-boxed and the review of the code was solely on the security aspects of the Solidity implementation of the contracts.

# Risk Classification

|            |        | Impact |        |     |
| ---------- | ------ | ------ | ------ | --- |
|            |        | High   | Medium | Low |
|            | High   | H      | H/M    | M   |
| Likelihood | Medium | H/M    | M      | M/L |
|            | Low    | M      | M/L    | L   |

We use the [CodeHawks](https://docs.codehawks.com/hawks-auditors/how-to-evaluate-a-finding-severity) severity matrix to determine severity. See the documentation for more details.

# Audit Details 
## Scope 
```
src/
#-- OrderBook.sol
```
## Roles
# Executive Summary
## Issues found

| Severity | Number of issues found |
| -------- | ---------------------- |
| Critical | 0                      |
| High     | 0                      |
| Medium   | 0                      |
| Low      | 1                      |
| Info     | 2                      |
| Gas      | 0                      |
| Total    | 0                      |

# Findings
## Low 
### [L-1] Fee Calculation Precision Loss Due to Integer Division Rounding

**Sumary:** The protocol is designed to collect a 3% fee on all order transactions to generate revenue for the platform. The fee calculation uses integer division which rounds down, causing small orders to result in zero fees and allowing users to bypass protocol fees entirely, leading to significant revenue loss.

**Vulnerability Details:** Users frequently place small orders in DeFi protocols, especially for testing or small trades. Attackers can deliberately structure transactions to minimize fees through precision loss exploitation
```javascript
function buyOrder(uint256 _orderId) public {
    // ... validation checks ...
    
    order.isActive = false;
    
    // @> Integer division rounds down, causing precision loss
    uint256 protocolFee = (order.priceInUSDC * FEE) / PRECISION;
    uint256 sellerReceives = order.priceInUSDC - protocolFee;
    
    // @> Small orders may result in zero fees due to rounding
    iUSDC.safeTransferFrom(msg.sender, address(this), protocolFee);
    iUSDC.safeTransferFrom(msg.sender, order.seller, sellerReceives);
    IERC20(order.tokenToSell).safeTransfer(msg.sender, order.amountToSell);
    
    totalFees += protocolFee;
    
    emit OrderFilled(_orderId, msg.sender, order.seller);
}
```

**Impact:**

- Protocol loses significant revenue from small orders that should generate fees but result in zero due to rounding
- Users can exploit the rounding behavior to trade without paying fees by keeping order values below fee threshold
- Unfair fee distribution where large orders pay proportionally more while small orders pay nothing
- Potential for systematic fee avoidance through order splitting strategies

**Proof of Concept:** The integer division rounding issue can be demonstrated with specific order values that result in zero fees:

- **Zero Fee Examples:** Orders with priceInUSDC values that result in zero fees due to rounding down:
```javascript
// Fee calculation: protocolFee = (priceInUSDC * 3) / 100
​
// Example 1: Small order results in zero fee
uint256 priceInUSDC = 33; // 33 USDC order
uint256 protocolFee = (33 * 3) / 100 = 99 / 100 = 0; // Rounds down to 0
// User pays 0 fees instead of expected 0.99 USDC
​
// Example 2: Slightly larger order still results in zero fee  
uint256 priceInUSDC = 32; // 32 USDC order
uint256 protocolFee = (32 * 3) / 100 = 96 / 100 = 0; // Rounds down to 0
// User pays 0 fees instead of expected 0.96 USDC
​
// Example 3: Threshold where fee becomes non-zero
uint256 priceInUSDC = 34; // 34 USDC order  
uint256 protocolFee = (34 * 3) / 100 = 102 / 100 = 1; // Rounds down to 1
// User pays 1 USDC fee instead of expected 1.02 USDC
```

**Fee Avoidance Attack:** Malicious users can exploit this by splitting large orders into smaller ones:
```javascript
// Instead of one large order:
// priceInUSDC = 3300 → protocolFee = (3300 * 3) / 100 = 99 USDC
​
// Attacker splits into 100 small orders:
// 100 orders × 33 USDC each = 3300 USDC total
// Each order: protocolFee = (33 * 3) / 100 = 0 USDC
// Total fees paid: 100 × 0 = 0 USDC instead of 99 USDC
```

**Recommended Mitigation:** Implement minimum fee requirements and consider using higher precision calculations to reduce the impact of integer division rounding or an alternative Solution higher precision.

## Informational
### [I-1] Public Function Not Used Internally - Should Be External
**Sumary:** Functions should use the most restrictive visibility modifier appropriate for their intended use to optimize gas consumption and improve code clarity. Several functions are marked as public but are never called internally within the contract, meaning they should be marked as external to reduce gas costs and improve the contract's interface design.

**Vulnerability Details:** Gas inefficiency occurs on every function call since public functions generate additional code for internal accessibility. Code clarity issues arise when function visibility doesn't match actual usage patterns.

```javascript
contract OrderBook is Ownable {
    // @> Functions marked public but only called externally
    function createSellOrder(
        address _tokenAddress,
        uint256 _amount,
        uint256 _pricePerToken
    ) public {
        // Function implementation...
    }
​
    function amendSellOrder(
        uint256 _orderId,
        uint256 _newAmount,
        uint256 _newPricePerToken
    ) public {
        // @> Never called internally, should be external
        // Function implementation...
    }
​
    function cancelSellOrder(uint256 _orderId) public {
        // @> Never called internally, should be external
        // Function implementation...
    }
​
    function buyOrder(uint256 _orderId) public {
        // @> Never called internally, should be external
        // Function implementation...
    }
​
    function getOrder(uint256 _orderId) public view returns (Order memory orderDetails) {
        // @> Never called internally, should be external
        // Function implementation...
    }
​
    function getOrderDetailsString(uint256 _orderId) public view returns (string memory details) {
        // @> Never called internally, should be external
        // Function implementation...
    }
}
```

**Impact:**

- Increased gas costs for users calling these functions due to unnecessary internal call handling overhead
- Reduced code maintainability and clarity as visibility modifiers don't accurately reflect function usage
- Potential confusion for developers who might assume these functions are used internally when they are not
- Larger contract bytecode size due to additional internal call handling code generation

**Proof of Concept:**
The gas difference between public and external functions can be demonstrated through gas consumption analysis:

- **Gas Cost Analysis:** Public functions consume more gas because the compiler generates additional code to handle both internal and external calls:
```javascript
// Current implementation - higher gas cost
function createSellOrder(
    address _tokenAddress,
    uint256 _amount,
    uint256 _pricePerToken
) public {
    // Compiler generates code for both internal and external calls
    // Even though internal calls never happen
}
​
// Optimized implementation - lower gas cost  
function createSellOrder(
    address _tokenAddress,
    uint256 _amount,
    uint256 _pricePerToken
) external {
    // Compiler only generates code for external calls
    // Reduces gas overhead
}
```

**Recommended Mitigation:**
Change the visibility of functions that are only called externally from `public` to `external` to optimize gas usage and improve code clarity:
```diff
- function createSellOrder(
+ function createSellOrder(
      address _tokenAddress,
      uint256 _amount,
      uint256 _pricePerToken
- ) public {
+ ) external {
      // Function implementation remains the same
  }
​
- function amendSellOrder(
+ function amendSellOrder(
      uint256 _orderId,
      uint256 _newAmount,
      uint256 _newPricePerToken
- ) public {
+ ) external {
      // Function implementation remains the same
  }
​
- function cancelSellOrder(uint256 _orderId) public {
+ function cancelSellOrder(uint256 _orderId) external {
      // Function implementation remains the same
  }
​
- function buyOrder(uint256 _orderId) public {
+ function buyOrder(uint256 _orderId) external {
      // Function implementation remains the same
  }
​
- function getOrder(uint256 _orderId) public view returns (Order memory orderDetails) {
+ function getOrder(uint256 _orderId) external view returns (Order memory orderDetails) {
      // Function implementation remains the same
  }
​
- function getOrderDetailsString(uint256 _orderId) public view returns (string memory details) {
+ function getOrderDetailsString(uint256 _orderId) external view returns (string memory details) {
      // Function implementation remains the same
  }
```

### [I-2] Empty Token Symbol Returned for Non-Standard Allowed Tokens
**Sumary:** The getOrderDetailsString function is designed to return human-readable order details including a token symbol for the asset being sold. The function only handles three hardcoded tokens (wETH, wBTC, wSOL) but fails to provide a symbol for other tokens that may be allowed via setAllowedSellToken(), resulting in empty token symbols in the output string.

**Vulnerability Details:** The owner can add new allowed tokens using setAllowedSellToken() at any time. Users can create sell orders for these newly allowed tokens through createSellOrder(). Any call to getOrderDetailsString() for orders with non-standard tokens will produce incomplete information.
```javascript
function getOrderDetailsString(uint256 _orderId) public view returns (string memory details) {
    Order storage order = orders[_orderId];
    if (order.seller == address(0)) revert OrderNotFound();
​
    string memory tokenSymbol;
    if (order.tokenToSell == address(iWETH)) {
        tokenSymbol = "wETH";
    } else if (order.tokenToSell == address(iWBTC)) {
        tokenSymbol = "wBTC";
    } else if (order.tokenToSell == address(iWSOL)) {
        tokenSymbol = "wSOL";
    }
    // @> No else clause - tokenSymbol remains empty for other allowed tokens
    
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
            tokenSymbol, // @> Will be empty string for non-standard tokens
            "\n",
            "Asking Price: ",
            order.priceInUSDC.toString(),
            " USDC\n"
        )
    );
```

**Impact:**

-User interfaces consuming this function will display confusing order details with missing token information
-Order details will show "Selling: 1000000 " instead of "Selling: 1000000 USDT" for example
-This creates poor user experience and potential confusion about what asset is being traded

**Proof of Concept:** As you can see from the console.log() the details contains an empty strings.
```bash
[PASS] test_emptyTokenSymbolForNonStandardTokens() (gas: 1270950)
Logs:
  Order Details:
  Order ID: 1
Seller: 0xaf6db259343d020e372f4ab69cad536aaf79d0ac
Selling: 1000000 
Asking Price: 1000000 USDC
Deadline Timestamp: 86401
Status: Active
```
```javascript
function test_emptyTokenSymbolForNonStandardTokens() public {
    // Deploy a new mock token (e.g., USDT)
    MockUSDC usdt = new MockUSDC(6);
    usdt.mint(alice, 1000000);
    
    // Owner adds the new token as allowed
    vm.prank(owner);
    book.setAllowedSellToken(address(usdt), true);
    
    // Alice creates an order with the new token
    vm.startPrank(alice);
    usdt.approve(address(book), 1000000);
    uint256 orderId = book.createSellOrder(address(usdt), 1000000, 1000000, 1 days);
    vm.stopPrank();
    
    // Get order details string
    string memory details = book.getOrderDetailsString(orderId);
    
    // The output will contain "Selling: 1000000 " with empty token symbol
    // Expected output should be "Selling: 1000000 USDT" or show the token address
    console2.log("Order Details:");
    console2.log(details);
    
    // Assert that the details contain empty space after the amount
    // This demonstrates the missing token symbol issue
    assertTrue(bytes(details).length > 0);
}
```

**Recommended Mitigation:** Add a fallback mechanism to display the token address when no predefined symbol exists. This ensures users always know which token is being traded:
```diff
string memory tokenSymbol;
if (order.tokenToSell == address(iWETH)) {
    tokenSymbol = "wETH";
} else if (order.tokenToSell == address(iWBTC)) {
    tokenSymbol = "wBTC";
} else if (order.tokenToSell == address(iWSOL)) {
    tokenSymbol = "wSOL";
+} else {
+    // Fallback to showing the token address for non-standard tokens
+    tokenSymbol = Strings.toHexString(uint160(order.tokenToSell), 20);
}
```

### [I-3] Inconsistent Order Existence Check + Code Quality Issue
**Sumary:** The contract should check if an order exists by verifying the order ID, since order IDs start from 1 and any order with ID 0 definitively doesn't exist. The current implementation checks if the seller address is the zero address, which indirectly detects non-existent orders but is less explicit and potentially confusing.

**Vulnerability Details:** The current implementation works correctly in normal circumstances since orders are properly initialized with valid seller addresses. Edge cases or future code changes could potentially cause confusion about the intent of the validation check
```javascript
function getOrder(uint256 _orderId) public view returns (Order memory orderDetails) {
@>  if (orders[_orderId].seller == address(0)) revert OrderNotFound();
    orderDetails = orders[_orderId];
}
​
function amendSellOrder(
    uint256 _orderId,
    uint256 _newAmountToSell,
    uint256 _newPriceInUSDC,
    uint256 _newDeadlineDuration
) public {
    Order storage order = orders[_orderId];
​
@>  if (order.seller == address(0)) revert OrderNotFound(); // Check if order exists
    if (order.seller != msg.sender) revert NotOrderSeller();
    // ... rest of function
}
​
function getOrderDetailsString(uint256 _orderId) public view returns (string memory details) {
    Order storage order = orders[_orderId];
@>  if (order.seller == address(0)) revert OrderNotFound(); // Check if order exists
    // ... rest of function
}
```

**Impact:**

- Code clarity and maintainability are reduced due to indirect order existence checking
- Potential for misunderstanding the validation logic during code reviews or future modifications
- No direct impact on funds or core functionality under normal operation

**Proof of Concept:** The issue stems from the contract's design where order IDs are explicitly managed to start from 1, making ID 0 a reliable indicator of non-existence. When an order is created, it's assigned an ID from `_nextOrderId` which begins at 1 and increments with each new order. This means any mapping lookup that returns an order with ID 0 represents an uninitialized/non-existent order.
```javascript
// Current check is indirect and less clear
if (order.seller == address(0)) revert OrderNotFound();
​
// Since _nextOrderId starts at 1 in constructor:
constructor(...) {
    _nextOrderId = 1; // Start order IDs from 1
}
​
// Any order with id == 0 definitively doesn't exist
// This would be more explicit and intentional
```

**Recommended Mitigation:** The fix involves replacing the seller address check with an order ID check. Since order IDs start from 1 and are managed by the contract, checking `order.id == 0` provides a more explicit and semantically correct way to verify order existence. This change improves code readability and makes the validation logic more intentional and less prone to confusion.
```diff
function getOrder(uint256 _orderId) public view returns (Order memory orderDetails) {
-   if (orders[_orderId].seller == address(0)) revert OrderNotFound();
+   if (orders[_orderId].id == 0) revert OrderNotFound();
    orderDetails = orders[_orderId];
}
​
function amendSellOrder(
    uint256 _orderId,
    uint256 _newAmountToSell,
    uint256 _newPriceInUSDC,
    uint256 _newDeadlineDuration
) public {
    Order storage order = orders[_orderId];
​
-   if (order.seller == address(0)) revert OrderNotFound();
+   if (order.id == 0) revert OrderNotFound();
    if (order.seller != msg.sender) revert NotOrderSeller();
    // ... rest of function
}
​
function getOrderDetailsString(uint256 _orderId) public view returns (string memory details) {
    Order storage order = orders[_orderId];
-   if (order.seller == address(0)) revert OrderNotFound();
+   if (order.id == 0) revert OrderNotFound();
    // ... rest of function
}
```