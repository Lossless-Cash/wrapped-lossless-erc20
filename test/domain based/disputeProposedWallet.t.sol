// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "../utils/losslessEnv.t.sol";

contract DisputeProposeWallet is LosslessTestEnvironment {
    function testDisputeProposeWalletByLssTeam()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
        withReportsSolvedPositively
    {
        lssGovernance.proposeWallet(1, retrievalReceiver);
        lssGovernance.proposeWallet(2, retrievalReceiver);
    }

    function testDisputeProposeWalletTwice()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
        withReportsSolvedPositively
    {
        lssGovernance.proposeWallet(1, retrievalReceiver);
        lssGovernance.proposeWallet(2, retrievalReceiver);

        vm.expectRevert("LSS: Wallet already proposed");
        lssGovernance.proposeWallet(1, retrievalReceiver);
        vm.expectRevert("LSS: Wallet already proposed");
        lssGovernance.proposeWallet(2, retrievalReceiver);
    }

    function testDisputeProposeWalletByTokenOwner()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
        withReportsSolvedPositively
    {
        vm.startPrank(tokenOwner);
        lssGovernance.proposeWallet(2, retrievalReceiver);
        vm.stopPrank();
    }

    function testDisputeProposeWalletByRandomAddress()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
        withReportsSolvedPositively
    {
        vm.startPrank(address(3001));
        vm.expectRevert("LSS: Role cannot propose");
        lssGovernance.proposeWallet(2, retrievalReceiver);
        vm.stopPrank();
    }

    function testDisputeProposeWalletRejection()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
        withReportsSolvedPositively
    {
        lssGovernance.proposeWallet(1, retrievalReceiver);
        lssGovernance.proposeWallet(2, retrievalReceiver);

        lssGovernance.rejectWallet(1);
        lssGovernance.rejectWallet(2);
    }

    function testDisputeProposeWalletRejectionTwice()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
        withReportsSolvedPositively
    {
        lssGovernance.proposeWallet(1, retrievalReceiver);
        lssGovernance.proposeWallet(2, retrievalReceiver);

        lssGovernance.rejectWallet(1);
        lssGovernance.rejectWallet(2);

        vm.expectRevert("LSS: Already Voted");
        lssGovernance.rejectWallet(1);
        vm.expectRevert("LSS: Already Voted");
        lssGovernance.rejectWallet(2);
    }

    function testDisputeProposeWalletRejectByRandomAddress()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
        withReportsSolvedPositively
    {
        lssGovernance.proposeWallet(1, retrievalReceiver);
        lssGovernance.proposeWallet(2, retrievalReceiver);

        vm.startPrank(address(3001));
        vm.expectRevert("LSS: Role cannot reject.");
        lssGovernance.rejectWallet(2);
        vm.stopPrank();
    }

    function testDisputeProposeWalletRejectByLssTeamAfterDisputePeriod()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
        withReportsSolvedPositively
    {
        lssGovernance.proposeWallet(1, retrievalReceiver);
        lssGovernance.proposeWallet(2, retrievalReceiver);

        vm.warp(8 days);

        vm.expectRevert("LSS: Dispute period closed");
        lssGovernance.rejectWallet(1);
        vm.expectRevert("LSS: Dispute period closed");
        lssGovernance.rejectWallet(2);
    }

    function testDisputeProposeWalletClaimAfterReject()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
        withReportsSolvedPositively
    {
        lssGovernance.proposeWallet(1, retrievalReceiver);
        lssGovernance.proposeWallet(2, retrievalReceiver);

        lssGovernance.rejectWallet(1);
        lssGovernance.rejectWallet(2);

        for (uint256 i = 0; i < committeeMembers.length; i++) {
            vm.startPrank(committeeMembers[i]);
            lssGovernance.rejectWallet(1);
            lssGovernance.rejectWallet(2);
            vm.stopPrank();
        }

        vm.warp(walletDispute + 1 days);

        vm.startPrank(retrievalReceiver);
        vm.expectRevert("LSS: Wallet rejected");
        lssGovernance.retrieveFunds(1);
        vm.expectRevert("LSS: Wallet rejected");
        lssGovernance.retrieveFunds(2);
        vm.stopPrank();
    }

    function testDisputeProposeWalletProposeAfterReject()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
        withReportsSolvedPositively
    {
        lssGovernance.proposeWallet(1, retrievalReceiver);
        lssGovernance.proposeWallet(2, retrievalReceiver);

        lssGovernance.rejectWallet(1);
        lssGovernance.rejectWallet(2);

        for (uint256 i = 0; i < committeeMembers.length; i++) {
            vm.startPrank(committeeMembers[i]);
            lssGovernance.rejectWallet(1);
            lssGovernance.rejectWallet(2);
            vm.stopPrank();
        }

        vm.warp(walletDispute + 1 days);

        lssGovernance.proposeWallet(1, retrievalReceiver);
        lssGovernance.proposeWallet(2, retrievalReceiver);
    }

    function testDisputeProposeWalletProposeAfterRejectAndClaim()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
        withReportsSolvedPositively
    {
        lssGovernance.proposeWallet(1, retrievalReceiver);
        lssGovernance.proposeWallet(2, retrievalReceiver);

        lssGovernance.rejectWallet(1);
        lssGovernance.rejectWallet(2);

        for (uint256 i = 0; i < committeeMembers.length; i++) {
            vm.startPrank(committeeMembers[i]);
            lssGovernance.rejectWallet(1);
            lssGovernance.rejectWallet(2);
            vm.stopPrank();
        }

        vm.warp(walletDispute + 1 days);

        lssGovernance.proposeWallet(1, retrievalReceiver);
        lssGovernance.proposeWallet(2, retrievalReceiver);

        vm.warp(16 days);

        vm.startPrank(retrievalReceiver);
        lssGovernance.retrieveFunds(1);
        lssGovernance.retrieveFunds(2);
        vm.stopPrank();
    }
}
