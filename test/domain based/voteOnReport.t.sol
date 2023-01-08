// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "../utils/losslessEnv.t.sol";

contract VoteOnReport is LosslessTestEnvironment {
    function testVoteOnReportLosslessTeam()
        public
        withExtensibleCoreProtected
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        lssGovernance.losslessVote(1, true);
        lssGovernance.losslessVote(2, true);
        lssGovernance.losslessVote(3, true);

        assertEq(lssGovernance.getIsVoted(1, 0), true);
        assertEq(lssGovernance.getIsVoted(2, 0), true);
        assertEq(lssGovernance.getIsVoted(3, 0), true);
    }

    function testVoteOnReportOnlyOnePilarVote()
        public
        withExtensibleCoreProtected
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        lssGovernance.losslessVote(1, true);
        lssGovernance.losslessVote(2, true);
        lssGovernance.losslessVote(3, true);

        vm.expectRevert("LSS: Not enough votes");
        lssGovernance.resolveReport(1);
        vm.expectRevert("LSS: Not enough votes");
        lssGovernance.resolveReport(2);
        vm.expectRevert("LSS: Not enough votes");
        lssGovernance.resolveReport(3);
    }

    function testVoteOnReportOnInvalidReport()
        public
        withExtensibleCoreProtected
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        vm.expectRevert("LSS: report is not valid");
        lssGovernance.losslessVote(10, true);
        vm.expectRevert("LSS: report is not valid");
        lssGovernance.losslessVote(20, true);
        vm.expectRevert("LSS: report is not valid");
        lssGovernance.losslessVote(30, true);
    }

    function testVoteOnReportLosslessTeamTwoTimes()
        public
        withExtensibleCoreProtected
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        lssGovernance.losslessVote(1, true);
        lssGovernance.losslessVote(2, true);
        lssGovernance.losslessVote(3, true);

        vm.expectRevert("LSS: LSS already voted");
        lssGovernance.losslessVote(1, true);
        vm.expectRevert("LSS: LSS already voted");
        lssGovernance.losslessVote(2, true);
        vm.expectRevert("LSS: LSS already voted");
        lssGovernance.losslessVote(3, true);
    }

    function testVoteOnReportOnResolvedReport()
        public
        withExtensibleCoreProtected
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
        withReportsSolvedPositively
    {
        vm.expectRevert("LSS: Report already solved");
        lssGovernance.losslessVote(1, true);
        vm.expectRevert("LSS: Report already solved");
        lssGovernance.losslessVote(2, true);
        vm.expectRevert("LSS: Report already solved");
        lssGovernance.losslessVote(3, true);
    }

    function testVoteOnReportTokenOwnerVote()
        public
        withExtensibleCoreProtected
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        vm.startPrank(tokenOwner);
        vm.expectRevert("LSS: Must be token owner");
        lssGovernance.tokenOwnersVote(1, true);
        lssGovernance.tokenOwnersVote(2, true);
        lssGovernance.tokenOwnersVote(3, true);
        vm.stopPrank();

        assertEq(lssGovernance.getIsVoted(2, 1), true);
        assertEq(lssGovernance.getIsVoted(3, 1), true);
    }

    function testVoteOnReportTokenOwnerVoteTwice()
        public
        withExtensibleCoreProtected
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        vm.startPrank(tokenOwner);
        vm.expectRevert("LSS: Must be token owner");
        lssGovernance.tokenOwnersVote(1, true);
        lssGovernance.tokenOwnersVote(2, true);
        lssGovernance.tokenOwnersVote(3, true);

        vm.expectRevert("LSS: Must be token owner");
        lssGovernance.tokenOwnersVote(1, true);
        vm.expectRevert("LSS: owners already voted");
        lssGovernance.tokenOwnersVote(2, true);
        vm.expectRevert("LSS: owners already voted");
        lssGovernance.tokenOwnersVote(3, true);
        vm.stopPrank();
    }

    function testVoteOnReportTokenOwnerVoteOnClosedReport()
        public
        withExtensibleCoreProtected
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
        withReportsSolvedPositively
    {
        vm.startPrank(tokenOwner);
        vm.expectRevert("LSS: Report already solved");
        lssGovernance.tokenOwnersVote(1, true);
        vm.expectRevert("LSS: Report already solved");
        lssGovernance.tokenOwnersVote(2, true);
        vm.expectRevert("LSS: Report already solved");
        lssGovernance.tokenOwnersVote(3, true);
        vm.stopPrank();
    }
}
