// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./utils/losslessEnv.t.sol";

contract WrappedERC20Test is LosslessTestEnvironment {
    function testAdminlessProtectedWLERC20()
        public
        withAdminlessProtectedWrappedToken
    {}

    /// @notice Test Committee members claiming their rewards when all participating
    /// @dev Should not revert and update balances correctly
    ///      reported amount * committee rewards / all members
    function testAdminlessProtectedMembersClaimAllParticipating()
        public
        withAdminlessProtectedWrappedToken
    {
        uint256[5] memory memberBalances;

        for (uint256 i = 0; i < committeeMembers.length; i++) {
            memberBalances[i] = wLERC20a.balanceOf(committeeMembers[i]);
        }

        uint256 reportId = generateReport(
            address(wLERC20a),
            maliciousActor,
            reporter,
            wLERC20a
        );

        solveReportPositively(reportId);

        for (uint256 i = 0; i < committeeMembers.length; i++) {
            vm.prank(committeeMembers[i]);
            lssGovernance.claimCommitteeReward(reportId);
            uint256 newBalance = memberBalances[i] +
                ((reportedAmount * committeeReward) / 1e2) /
                committeeMembers.length;
            assertEq(wLERC20a.balanceOf(committeeMembers[i]), newBalance + 4);
        }
    }

    /// @notice Test Committee members claiming their rewards when some participating
    /// @dev Should not revert and update balances correctly
    ///      reported amount * committee rewards / all members
    function testAdminlessProtectedMembersClaimSomeParticipating()
        public
        withAdminlessProtectedWrappedToken
    {
        uint256 totalMembers = committeeMembers.length;
        uint256[5] memory memberBalances;
        uint256 participatingMembers = 3;

        for (uint256 i = 0; i < totalMembers; i++) {
            memberBalances[i] = wLERC20a.balanceOf(committeeMembers[i]);
        }

        uint256 reportId = generateReport(
            address(wLERC20a),
            maliciousActor,
            reporter,
            wLERC20a
        );
        solveReport(reportId, participatingMembers, true, true, true);

        for (uint256 i = 0; i < totalMembers; i++) {
            vm.startPrank(committeeMembers[i]);
            if (i < participatingMembers) {
                lssGovernance.claimCommitteeReward(reportId);
                uint256 newBalance = memberBalances[i] +
                    ((reportedAmount * committeeReward) / 1e2) /
                    participatingMembers;
                assertEq(
                    wLERC20a.balanceOf(committeeMembers[i]),
                    newBalance + 7
                );
            } else {
                vm.expectRevert("LSS: Did not vote on report");
                lssGovernance.claimCommitteeReward(reportId);
            }
            vm.stopPrank();
        }
    }

    /// @notice Test Rewards distribution to Lossless Contracts whent everyone participates
    /// @dev Should not revert and transfer correctly
    function testAdminlessProtectedRewardDistributionFull()
        public
        withAdminlessProtectedWrappedToken
    {
        uint256 participatingMembers = 3;
        uint256 participatingStakers = 3;
        uint256 expectedToRetrieve = reportedAmount -
            ((reportedAmount *
                (committeeReward +
                    stakersReward +
                    reporterReward +
                    losslessReward)) / 1e2);

        uint256 reportId = generateReport(
            address(wLERC20a),
            maliciousActor,
            reporter,
            wLERC20a
        );
        stakeOnReport(reportId, participatingStakers, 30 minutes);

        solveReport(reportId, participatingMembers, true, true, true);

        (, , uint256 fundsToRetrieve, , , , , , , , ) = lssGovernance
            .proposedWalletOnReport(reportId);

        assertApproxEqAbs(fundsToRetrieve, expectedToRetrieve, 5000);
    }

    /// @notice Test Rewards distribution to Lossless Contracts whent nobody stakes
    /// @dev Should not revert and transfer correctly
    function testAdminlessProtectedRewardDistributionNoStakes()
        public
        withAdminlessProtectedWrappedToken
    {
        uint256 participatingMembers = 3;
        uint256 expectedToRetrieve = reportedAmount -
            ((reportedAmount *
                (reporterReward + committeeReward + losslessReward)) / 1e2);

        uint256 reportId = generateReport(
            address(wLERC20a),
            maliciousActor,
            reporter,
            wLERC20a
        );

        solveReport(reportId, participatingMembers, true, true, true);

        (, , uint256 fundsToRetrieve, , , , , , , , ) = lssGovernance
            .proposedWalletOnReport(reportId);

        assertApproxEqAbs(fundsToRetrieve, expectedToRetrieve, 5000);
    }

    /// @notice Test Rewards distribution to Lossless Contracts whent nobody stakes and committee does not participate
    /// @dev Should not revert and transfer correctly
    function testAdminlessProtectedRewardDistributionNoStakesNoCommittee()
        public
        withAdminlessProtectedWrappedToken
    {
        uint256 reportId = generateReport(
            address(wLERC20a),
            maliciousActor,
            reporter,
            wLERC20a
        );

        vm.prank(address(this));
        lssGovernance.losslessVote(reportId, true);

        (, , , , ILERC20 reportedToken, , ) = lssReporting.getReportInfo(
            reportId
        );

        if (address(reportedToken) != address(wLERC20a)) {
            vm.prank(reportedToken.admin());
            lssGovernance.tokenOwnersVote(reportId, true);
        }

        vm.expectRevert("LSS: Not enough votes");
        lssGovernance.resolveReport(reportId);
    }
}
