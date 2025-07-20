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
