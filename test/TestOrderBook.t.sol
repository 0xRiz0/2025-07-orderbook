// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";
import {OrderBook} from "../src/OrderBook.sol";
import {MockUSDC} from "./mocks/MockUSDC.sol";
import {MockWBTC} from "./mocks/MockWBTC.sol";
import {MockWETH} from "./mocks/MockWETH.sol";
import {MockWSOL} from "./mocks/MockWSOL.sol";

contract TestOrderBook is Test {
    OrderBook book;

    MockUSDC usdc;
    MockWBTC wbtc;
    MockWETH weth;
    MockWSOL wsol;

    address owner;
    address alice;
    address bob;
    address clara;
    address dan;

    uint256 mdd;

    function setUp() public {
        owner = makeAddr("protocol_owner");
        alice = makeAddr("will_sell_wbtc_order");
        bob = makeAddr("will_sell_weth_order");
        clara = makeAddr("will_sell_wsol_order");
        dan = makeAddr("will_buy_orders");

        usdc = new MockUSDC(6);
        wbtc = new MockWBTC(8);
        weth = new MockWETH(18);
        wsol = new MockWSOL(18);

        vm.prank(owner);
        book = new OrderBook(address(weth), address(wbtc), address(wsol), address(usdc), owner);

        usdc.mint(dan, 200_000);
        wbtc.mint(alice, 2);
        weth.mint(bob, 2);
        wsol.mint(clara, 2);

        mdd = book.MAX_DEADLINE_DURATION();
    }

    function test_init() public view {
        assert(usdc.balanceOf(dan) == 200_000e6);
        assert(wbtc.balanceOf(alice) == 2e8);
        assert(weth.balanceOf(bob) == 2e18);
        assert(wsol.balanceOf(clara) == 2e18);

        assert(mdd == 3 days);
    }

    function test_createSellOrder() public {
        // alice creates sell order for wbtc
        vm.startPrank(alice);
        wbtc.approve(address(book), 2e8);
        uint256 aliceId = book.createSellOrder(address(wbtc), 2e8, 180_000e6, 2 days);
        vm.stopPrank();

        assert(aliceId == 1);
        assert(wbtc.balanceOf(alice) == 0);
        assert(wbtc.balanceOf(address(book)) == 2e8);

        // bob creates sell order for weth
        vm.startPrank(bob);
        weth.approve(address(book), 2e18);
        uint256 bobId = book.createSellOrder(address(weth), 2e18, 5_000e6, 2 days);
        vm.stopPrank();

        assert(bobId == 2);
        assert(weth.balanceOf(bob) == 0);
        assert(weth.balanceOf(address(book)) == 2e18);

        // clara creates sell order for wsol
        vm.startPrank(clara);
        wsol.approve(address(book), 2e18);
        uint256 claraId = book.createSellOrder(address(wsol), 2e18, 300e6, 2 days);
        vm.stopPrank();

        assert(claraId == 3);
        assert(wsol.balanceOf(clara) == 0);
        assert(wsol.balanceOf(address(book)) == 2e18);
    }

    function test_amendSellOrder() public {
        // alice creates sell order for wbtc
        vm.startPrank(alice);
        wbtc.approve(address(book), 2e8);
        uint256 aliceId = book.createSellOrder(address(wbtc), 2e8, 180_000e6, 2 days);
        vm.stopPrank();

        // bob creates sell order for weth
        vm.startPrank(bob);
        weth.approve(address(book), 2e18);
        uint256 bobId = book.createSellOrder(address(weth), 2e18, 5_000e6, 2 days);
        vm.stopPrank();

        // clara creates sell order for wsol
        vm.startPrank(clara);
        wsol.approve(address(book), 2e18);
        uint256 claraId = book.createSellOrder(address(wsol), 2e18, 300e6, 2 days);
        vm.stopPrank();

        vm.warp(block.timestamp + 1 days);

        // alice amends her wbtc sell order
        vm.prank(alice);
        book.amendSellOrder(aliceId, 1.75e8, 175_000e6, 0.5 days);
        string memory aliceOrderDetails = book.getOrderDetailsString(aliceId);
        console2.log(aliceOrderDetails);
        assert(wbtc.balanceOf(alice) == 0.25e8);
        assert(wbtc.balanceOf(address(book)) == 1.75e8);

        // bob amends his weth order
        vm.prank(bob);
        book.amendSellOrder(bobId, 1.75e18, 4_550e6, 0.5 days);
        string memory bobOrderDetails = book.getOrderDetailsString(bobId);
        console2.log(bobOrderDetails);
        assert(weth.balanceOf(bob) == 0.25e18);
        assert(weth.balanceOf(address(book)) == 1.75e18);

        // clara amends her wsol order
        vm.prank(clara);
        book.amendSellOrder(claraId, 1.75e18, 350e6, 0.5 days);
        string memory claraOrderDetails = book.getOrderDetailsString(claraId);
        console2.log(claraOrderDetails);
        assert(wsol.balanceOf(clara) == 0.25e18);
        assert(wsol.balanceOf(address(book)) == 1.75e18);
    }

    function test_cancelSellOrder() public {
        // alice creates sell order for wbtc
        vm.startPrank(alice);
        wbtc.approve(address(book), 2e8);
        uint256 aliceId = book.createSellOrder(address(wbtc), 2e8, 180_000e6, 2 days);
        vm.stopPrank();

        // bob creates sell order for weth
        vm.startPrank(bob);
        weth.approve(address(book), 2e18);
        uint256 bobId = book.createSellOrder(address(weth), 2e18, 5_000e6, 2 days);
        vm.stopPrank();

        // clara creates sell order for wsol
        vm.startPrank(clara);
        wsol.approve(address(book), 2e18);
        uint256 claraId = book.createSellOrder(address(wsol), 2e18, 300e6, 2 days);
        vm.stopPrank();

        // alice cancels wbtc sell order
        vm.prank(alice);
        book.cancelSellOrder(aliceId);

        // bob cancels weth order
        vm.prank(bob);
        book.cancelSellOrder(bobId);

        // clara cancels sell order
        vm.prank(clara);
        book.cancelSellOrder(claraId);
    }

    function test_buyOrder() public {
        // alice creates sell order for wbtc
        vm.startPrank(alice);
        wbtc.approve(address(book), 2e8);
        uint256 aliceId = book.createSellOrder(address(wbtc), 2e8, 180_000e6, 2 days);
        vm.stopPrank();

        assert(aliceId == 1);
        assert(wbtc.balanceOf(alice) == 0);
        assert(wbtc.balanceOf(address(book)) == 2e8);

        // bob creates sell order for weth
        vm.startPrank(bob);
        weth.approve(address(book), 2e18);
        uint256 bobId = book.createSellOrder(address(weth), 2e18, 5_000e6, 2 days);
        vm.stopPrank();

        assert(bobId == 2);
        assert(weth.balanceOf(bob) == 0);
        assert(weth.balanceOf(address(book)) == 2e18);

        // clara creates sell order for wsol
        vm.startPrank(clara);
        wsol.approve(address(book), 2e18);
        uint256 claraId = book.createSellOrder(address(wsol), 2e18, 300e6, 2 days);
        vm.stopPrank();

        vm.startPrank(dan);
        usdc.approve(address(book), 200_000e6);
        book.buyOrder(aliceId); // dan buys alice wbtc order
        book.buyOrder(bobId); // dan buys bob weth order
        book.buyOrder(claraId); // dan buys clara wsol order
        vm.stopPrank();

        assert(wbtc.balanceOf(dan) == 2e8);
        assert(weth.balanceOf(dan) == 2e18);
        assert(wsol.balanceOf(dan) == 2e18);

        assert(usdc.balanceOf(alice) == 174_600e6);
        assert(usdc.balanceOf(bob) == 4_850e6);
        assert(usdc.balanceOf(clara) == 291e6);

        assert(book.totalFees() == 5_559e6);

        vm.prank(owner);
        book.withdrawFees(owner);

        assert(usdc.balanceOf(owner) == 5_559e6);
    }

    function test_POC_buyOrder() public {
        usdc.mint(alice, 200_000e6); // Mint 200,000 USDC for Alice

        // alice creates sell order for wbtc
        vm.startPrank(alice);
        wbtc.approve(address(book), 2e8);
        uint256 aliceId = book.createSellOrder(address(wbtc), 2e8, 180_000e6, 2 days);
        vm.stopPrank();

        assert(aliceId == 1);
        assert(wbtc.balanceOf(alice) == 0);
        assert(wbtc.balanceOf(address(book)) == 2e8);

        vm.startPrank(alice);
        usdc.approve(address(book), 200_000e6); // Approve the full 200,000 USDC
        book.buyOrder(aliceId); // alice buys alice wbtc order
        vm.stopPrank();

        assert(wbtc.balanceOf(alice) == 2e8);
        assert(usdc.balanceOf(alice) == 199999994600000000);
    }
}
