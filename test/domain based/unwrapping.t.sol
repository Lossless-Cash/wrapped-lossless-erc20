// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import "../utils/losslessEnv.t.sol";

contract UnwrappingToken is LosslessTestEnvironment {
    function testUnwrappingTokenDelay()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
    {
        vm.startPrank(tokenOwner);
        wLERC20a.requestWithdraw(10);
        wLERC20p.requestWithdraw(10);

        vm.warp(block.timestamp + unwrappingDelay + 1 minutes);

        bool statusE = wLERC20a.withdrawTo(tokenOwner, 10);
        bool statusP = wLERC20p.withdrawTo(tokenOwner, 10);

        assertEq(statusP, true);
        assertEq(statusE, true);
        vm.stopPrank();
    }

    function testUnwrappingTokenBeforeDelay()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
    {
        vm.startPrank(tokenOwner);
        wLERC20a.requestWithdraw(10);
        wLERC20p.requestWithdraw(10);

        vm.warp(block.timestamp + 1 minutes);

        vm.expectRevert("LSS: Unwrapping not ready yet");
        wLERC20a.withdrawTo(tokenOwner, 10);
        vm.expectRevert("LSS: Unwrapping not ready yet");
        wLERC20p.withdrawTo(tokenOwner, 10);

        vm.stopPrank();
    }

    function testUnwrappingIncreasedAmount()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
    {
        vm.startPrank(tokenOwner);
        wLERC20a.requestWithdraw(10);
        wLERC20p.requestWithdraw(10);

        vm.warp(block.timestamp + unwrappingDelay + 1 minutes);

        vm.expectRevert("LSS: Amount exceeds requested amount");
        wLERC20a.withdrawTo(tokenOwner, 11);
        vm.expectRevert("LSS: Amount exceeds requested amount");
        wLERC20p.withdrawTo(tokenOwner, 11);

        vm.stopPrank();
    }

    function testUnwrappingWithoutRequest()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
    {
        vm.startPrank(tokenOwner);
        vm.expectRevert("LSS: Amount exceeds requested amount");
        wLERC20a.withdrawTo(tokenOwner, 10);
        vm.expectRevert("LSS: Amount exceeds requested amount");
        wLERC20p.withdrawTo(tokenOwner, 10);

        vm.stopPrank();
    }

    function testUnwrappingRequestWithPendingRequest()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
    {
        vm.startPrank(tokenOwner);
        wLERC20a.requestWithdraw(5);
        wLERC20p.requestWithdraw(5);

        vm.expectRevert("LSS: Pending withdraw");
        wLERC20a.requestWithdraw(5);
        vm.expectRevert("LSS: Pending withdraw");
        wLERC20p.requestWithdraw(5);

        vm.warp(block.timestamp + unwrappingDelay + 1 minutes);

        bool statusE = wLERC20a.withdrawTo(tokenOwner, 5);
        bool statusP = wLERC20p.withdrawTo(tokenOwner, 5);

        assertEq(statusP, true);
        assertEq(statusE, true);
        vm.stopPrank();
    }

    function testUnwrappingRequestCancel()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
    {
        vm.startPrank(tokenOwner);
        wLERC20a.requestWithdraw(10);
        wLERC20p.requestWithdraw(10);

        wLERC20a.cancelWithdrawRequest();
        wLERC20p.cancelWithdrawRequest();

        vm.warp(block.timestamp + unwrappingDelay + 1 minutes);

        vm.expectRevert("LSS: Amount exceeds requested amount");
        wLERC20a.withdrawTo(tokenOwner, 10);
        vm.expectRevert("LSS: Amount exceeds requested amount");
        wLERC20p.withdrawTo(tokenOwner, 10);

        vm.stopPrank();
    }

    function testUnwrappingRequestCancelAfterWithdraw()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
    {
        vm.startPrank(tokenOwner);
        wLERC20a.requestWithdraw(10);
        wLERC20p.requestWithdraw(10);

        vm.warp(block.timestamp + unwrappingDelay + 1 minutes);

        wLERC20a.withdrawTo(tokenOwner, 10);
        wLERC20p.withdrawTo(tokenOwner, 10);

        vm.expectRevert("LSS: No active withdrawal request");
        wLERC20a.cancelWithdrawRequest();
        vm.expectRevert("LSS: No active withdrawal request");
        wLERC20p.cancelWithdrawRequest();

        vm.stopPrank();
    }

    function testUnwrappingRequestCancelAfterDelayPeriodAndNoWithdraw()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
    {
        vm.startPrank(tokenOwner);
        wLERC20a.requestWithdraw(10);
        wLERC20p.requestWithdraw(10);

        vm.warp(block.timestamp + unwrappingDelay + 1 minutes);

        vm.expectRevert("LSS: Withdrawal request already executable");
        wLERC20a.cancelWithdrawRequest();
        vm.expectRevert("LSS: Withdrawal request already executable");
        wLERC20p.cancelWithdrawRequest();

        vm.stopPrank();
    }

    function testUnwrappingRequestCancelAndNewRequest()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
    {
        vm.startPrank(tokenOwner);
        wLERC20a.requestWithdraw(10);
        wLERC20p.requestWithdraw(10);

        wLERC20a.cancelWithdrawRequest();
        wLERC20p.cancelWithdrawRequest();

        wLERC20a.requestWithdraw(8);
        wLERC20p.requestWithdraw(8);

        vm.warp(block.timestamp + unwrappingDelay + 1 minutes);

        bool statusE = wLERC20a.withdrawTo(tokenOwner, 8);
        bool statusP = wLERC20p.withdrawTo(tokenOwner, 8);

        assertEq(statusP, true);
        assertEq(statusE, true);

        vm.stopPrank();
    }

    function testUnwrappingRequestCancelAfterHalfWithdraw()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
    {
        vm.startPrank(tokenOwner);
        wLERC20a.requestWithdraw(10);
        wLERC20p.requestWithdraw(10);

        vm.warp(block.timestamp + unwrappingDelay + 1 minutes);

        bool statusE = wLERC20a.withdrawTo(tokenOwner, 5);
        bool statusP = wLERC20p.withdrawTo(tokenOwner, 5);

        vm.expectRevert("LSS: Withdrawal request already executable");
        wLERC20a.cancelWithdrawRequest();
        vm.expectRevert("LSS: Withdrawal request already executable");
        wLERC20a.cancelWithdrawRequest();

        assertEq(statusP, true);
        assertEq(statusE, true);

        vm.stopPrank();
    }

    function testUnwrappingRequestCancelAndNewRequestPreviousAmount()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
    {
        vm.startPrank(tokenOwner);
        wLERC20a.requestWithdraw(10);
        wLERC20p.requestWithdraw(10);

        wLERC20a.cancelWithdrawRequest();
        wLERC20p.cancelWithdrawRequest();

        wLERC20a.requestWithdraw(8);
        wLERC20p.requestWithdraw(8);

        vm.warp(block.timestamp + unwrappingDelay + 1 minutes);

        vm.expectRevert("LSS: Amount exceeds requested amount");
        bool statusE = wLERC20a.withdrawTo(tokenOwner, 10);
        vm.expectRevert("LSS: Amount exceeds requested amount");
        bool statusP = wLERC20p.withdrawTo(tokenOwner, 10);

        assertEq(statusP, false);
        assertEq(statusE, false);

        vm.stopPrank();
    }

    function testUnwrappingRequestCancelAndNewRequestPreviousAmountInChunks()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
    {
        vm.startPrank(tokenOwner);
        wLERC20a.requestWithdraw(10);
        wLERC20p.requestWithdraw(10);

        wLERC20a.cancelWithdrawRequest();
        wLERC20p.cancelWithdrawRequest();

        wLERC20a.requestWithdraw(8);
        wLERC20p.requestWithdraw(8);

        vm.warp(block.timestamp + unwrappingDelay + 1 minutes);

        bool statusE = wLERC20a.withdrawTo(tokenOwner, 5);
        bool statusP = wLERC20p.withdrawTo(tokenOwner, 5);

        vm.expectRevert("LSS: Amount exceeds requested amount");
        wLERC20a.withdrawTo(tokenOwner, 5);
        vm.expectRevert("LSS: Amount exceeds requested amount");
        wLERC20p.withdrawTo(tokenOwner, 5);

        assertEq(statusP, true);
        assertEq(statusE, true);

        vm.stopPrank();
    }

    function testUnwrappingRequestCancelAndNewRequestAmountInChunks()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
    {
        vm.startPrank(tokenOwner);
        wLERC20a.requestWithdraw(10);
        wLERC20p.requestWithdraw(10);

        wLERC20a.cancelWithdrawRequest();
        wLERC20p.cancelWithdrawRequest();

        wLERC20a.requestWithdraw(8);
        wLERC20p.requestWithdraw(8);

        vm.warp(block.timestamp + unwrappingDelay + 1 minutes);

        bool statusE = wLERC20a.withdrawTo(tokenOwner, 5);
        bool statusP = wLERC20p.withdrawTo(tokenOwner, 5);

        statusE = wLERC20a.withdrawTo(tokenOwner, 3);
        statusE = wLERC20p.withdrawTo(tokenOwner, 3);

        assertEq(statusP, true);
        assertEq(statusE, true);

        vm.stopPrank();
    }
}
