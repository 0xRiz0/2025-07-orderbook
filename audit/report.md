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
| Low      | 0                      |
| Info     | 0                      |
| Gas      | 0                      |
| Total    | 0                      |

# Findings
## High
### [H-1]
**Sumary:**
**Vulnerability Details:**
**Impact:**
**Proof of Concept:**
**Recommended Mitigation:**

## Medium
### [M-1]

## Low 
### [L-1]

## Informational
### [I-1]

## Gas 
### [G-1]