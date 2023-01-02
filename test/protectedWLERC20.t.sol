// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./utils/losslessEnv.t.sol";

contract WrappedERC20Test is LosslessTestEnvironment {
    address[] retrieveFrom;

    /// @notice Test deployment
    function testProtectedWLERC20() public withProtectedWrappedToken {}

    function testProtectedTransferOutBlacklistedFundsFromNotController()
        public
    {
        address[] storage _retrieveFrom = retrieveFrom;
        _retrieveFrom.push(maliciousActor);

        vm.expectRevert();
        vm.prank(tokenOwner);
        wLERC20p.transferOutBlacklistedFunds(_retrieveFrom);
    }

    function testProtectedSetLosslessAdminFromNonRecovery()
        public
        withProtectedWrappedToken
    {
        vm.prank(maliciousActor);
        vm.expectRevert();
        wLERC20p.setLosslessAdmin(maliciousActor);
    }

    function testProtectedTransferRecoveryAdminFromNonRecovery()
        public
        withProtectedWrappedToken
    {
        vm.prank(maliciousActor);
        vm.expectRevert();
        wLERC20p.transferRecoveryAdminOwnership(
            maliciousActor,
            bytes32("12345")
        );
    }

    function testProtectedProposeLosslessTurnOffFromNonRecovery()
        public
        withProtectedWrappedToken
    {
        vm.prank(maliciousActor);
        vm.expectRevert();
        wLERC20p.proposeLosslessTurnOff();
    }

    /// @notice Test Committee members claiming their rewards when all participating
    /// @dev Should not revert and update balances correctly
    ///      reported amount * committee rewards / all members
    function testProtectedMembersClaimAllParticipating()
        public
        withProtectedWrappedToken
    {
        uint256[5] memory memberBalances;

        for (uint256 i = 0; i < committeeMembers.length; i++) {
            memberBalances[i] = wLERC20p.balanceOf(committeeMembers[i]);
        }

        uint256 reportId = generateReport(
            address(wLERC20p),
            maliciousActor,
            reporter,
            wLERC20p
        );

        solveReportPositively(reportId);

        for (uint256 i = 0; i < committeeMembers.length; i++) {
            vm.prank(committeeMembers[i]);
            lssGovernance.claimCommitteeReward(reportId);
            uint256 newBalance = memberBalances[i] +
                ((reportedAmount * committeeReward) / 1e2) /
                committeeMembers.length;
            assertEq(wLERC20p.balanceOf(committeeMembers[i]), newBalance);
        }
    }

    /// @notice Test Committee members claiming their rewards when some participating
    /// @dev Should not revert and update balances correctly
    ///      reported amount * committee rewards / all members
    function testProtectedMembersClaimSomeParticipating()
        public
        withProtectedWrappedToken
    {
        uint256 totalMembers = committeeMembers.length;
        uint256[5] memory memberBalances;
        uint256 participatingMembers = 3;

        for (uint256 i = 0; i < totalMembers; i++) {
            memberBalances[i] = wLERC20p.balanceOf(committeeMembers[i]);
        }

        uint256 reportId = generateReport(
            address(wLERC20p),
            maliciousActor,
            reporter,
            wLERC20p
        );
        solveReport(reportId, participatingMembers, true, true, true);

        for (uint256 i = 0; i < totalMembers; i++) {
            vm.startPrank(committeeMembers[i]);
            if (i < participatingMembers) {
                lssGovernance.claimCommitteeReward(reportId);
                uint256 newBalance = memberBalances[i] +
                    ((reportedAmount * committeeReward) / 1e2) /
                    participatingMembers;
                assertEq(wLERC20p.balanceOf(committeeMembers[i]), newBalance);
            } else {
                vm.expectRevert("LSS: Did not vote on report");
                lssGovernance.claimCommitteeReward(reportId);
            }
            vm.stopPrank();
        }
    }

    /// @notice Test Rewards distribution to Lossless Contracts whent everyone participates
    /// @dev Should not revert and transfer correctly
    function testProtectedRewardDistributionFull()
        public
        withProtectedWrappedToken
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
            address(wLERC20p),
            maliciousActor,
            reporter,
            wLERC20p
        );
        stakeOnReport(reportId, participatingStakers, 30 minutes);

        solveReport(reportId, participatingMembers, true, true, true);

        (, , uint256 fundsToRetrieve, , , , , , , , ) = lssGovernance
            .proposedWalletOnReport(reportId);

        assertApproxEqAbs(fundsToRetrieve, expectedToRetrieve, 5000);
    }

    /// @notice Test Rewards distribution to Lossless Contracts whent nobody stakes
    /// @dev Should not revert and transfer correctly
    function testProtectedRewardDistributionNoStakes()
        public
        withProtectedWrappedToken
    {
        uint256 participatingMembers = 3;
        uint256 expectedToRetrieve = reportedAmount -
            ((reportedAmount *
                (reporterReward + committeeReward + losslessReward)) / 1e2);

        uint256 reportId = generateReport(
            address(wLERC20p),
            maliciousActor,
            reporter,
            wLERC20p
        );

        solveReport(reportId, participatingMembers, true, true, true);

        (, , uint256 fundsToRetrieve, , , , , , , , ) = lssGovernance
            .proposedWalletOnReport(reportId);

        assertApproxEqAbs(fundsToRetrieve, expectedToRetrieve, 5000);
    }

    /// @notice Test Rewards distribution to Lossless Contracts whent nobody stakes and committee does not participate
    /// @dev Should not revert and transfer correctly
    function testProtectedRewardDistributionNoStakesNoCommittee()
        public
        withProtectedWrappedToken
    {
        uint256 participatingMembers = 0;
        uint256 expectedToRetrieve = reportedAmount -
            ((reportedAmount * (reporterReward + losslessReward)) / 1e2);

        uint256 reportId = generateReport(
            address(wLERC20p),
            maliciousActor,
            reporter,
            wLERC20p
        );

        solveReport(reportId, participatingMembers, true, true, true);

        (, , uint256 fundsToRetrieve, , , , , , , , ) = lssGovernance
            .proposedWalletOnReport(reportId);

        assertApproxEqAbs(fundsToRetrieve, expectedToRetrieve, 5000);
    }
}
