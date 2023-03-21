// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "../utils/losslessEnv.t.sol";

contract RetrievedFundsClaim is LosslessTestEnvironment {
    function testRetrieveFundsOnce()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
        withReportsSolvedPositively
    {
        uint256 adminlessBeforeBalance = wLERC20p.balanceOf(retrievalReceiver);
        uint256 protectedBeforeBalance = wLERC20a.balanceOf(retrievalReceiver);

        lssGovernance.proposeWallet(1, retrievalReceiver);
        lssGovernance.proposeWallet(2, retrievalReceiver);

        vm.warp(block.timestamp + 25 days);

        vm.startPrank(retrievalReceiver);
        lssGovernance.retrieveFunds(1);
        lssGovernance.retrieveFunds(2);
        vm.stopPrank();

        uint256 adminlessAfterBalance = wLERC20p.balanceOf(retrievalReceiver);
        uint256 protectedAfterBalance = wLERC20a.balanceOf(retrievalReceiver);

        assertGt(adminlessAfterBalance, adminlessBeforeBalance);
        assertGt(protectedAfterBalance, protectedBeforeBalance);
    }

    function testRetrieveFundsRetrievingTwice()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
        withReportsSolvedPositively
    {
        lssGovernance.proposeWallet(1, retrievalReceiver);
        lssGovernance.proposeWallet(2, retrievalReceiver);

        vm.warp(block.timestamp + 25 days);

        vm.startPrank(retrievalReceiver);
        lssGovernance.retrieveFunds(1);
        lssGovernance.retrieveFunds(2);

        vm.expectRevert("LSS: Funds already claimed");
        lssGovernance.retrieveFunds(1);
        vm.expectRevert("LSS: Funds already claimed");
        lssGovernance.retrieveFunds(2);
        vm.stopPrank();
    }

    function testRetrieveFundsByNonProposedWallet()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
        withReportsSolvedPositively
    {
        lssGovernance.proposeWallet(1, retrievalReceiver);
        lssGovernance.proposeWallet(2, retrievalReceiver);

        vm.warp(block.timestamp + 25 days);

        vm.startPrank(address(1200));
        vm.expectRevert("LSS: Only proposed adr can claim");
        lssGovernance.retrieveFunds(1);
        vm.expectRevert("LSS: Only proposed adr can claim");
        lssGovernance.retrieveFunds(2);
        vm.stopPrank();
    }

    function testRetrieveFundsWhenDisputePeriodNotOver()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
        withReportsSolvedPositively
    {
        lssGovernance.proposeWallet(1, retrievalReceiver);
        lssGovernance.proposeWallet(2, retrievalReceiver);

        vm.startPrank(retrievalReceiver);
        vm.expectRevert("LSS: Dispute period not closed");
        lssGovernance.retrieveFunds(1);
        vm.expectRevert("LSS: Dispute period not closed");
        lssGovernance.retrieveFunds(2);
        vm.stopPrank();
    }
}
