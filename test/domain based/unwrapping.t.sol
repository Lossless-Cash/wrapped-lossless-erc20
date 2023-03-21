// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

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
}
