// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "../utils/losslessEnv.t.sol";

contract StakeRewardsClaim is LosslessTestEnvironment {
    function testStakeRewardsClaimOnce()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        uint256 stakersBeforeBalanceProtected = 0;
        uint256 stakersBeforeBalanceAdminless = 0;

        for (uint256 i = 0; i < stakers.length; i++) {
            stakersBeforeBalanceAdminless += wLERC20a.balanceOf(stakers[i]);
            stakersBeforeBalanceProtected += wLERC20p.balanceOf(stakers[i]);
        }

        stakeOnReport(1, 5, 1 hours);
        stakeOnReport(2, 5, 1 hours);

        solveReportPositively(1);
        solveReportPositively(2);

        vm.warp(block.timestamp + settlementPeriod + 1 minutes);

        claimStakeOnReport(1);
        claimStakeOnReport(2);

        uint256 stakersAfterBalanceProtected = 0;
        uint256 stakersAfterBalanceAdminless = 0;

        for (uint256 i = 0; i < stakers.length; i++) {
            stakersAfterBalanceAdminless += wLERC20a.balanceOf(stakers[i]);
            stakersAfterBalanceProtected += wLERC20p.balanceOf(stakers[i]);
        }

        assertGt(stakersAfterBalanceProtected, stakersBeforeBalanceProtected);
        assertGt(stakersAfterBalanceAdminless, stakersBeforeBalanceAdminless);
    }

    function testStakeRewardsClaimNegativeReport()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        stakeOnReport(1, 5, 1 hours);
        stakeOnReport(2, 5, 1 hours);

        solveReportNegatively(1);
        solveReportNegatively(2);

        vm.startPrank(stakers[0]);
        vm.expectRevert("LSS: Report solved negatively");
        lssStaking.stakerClaim(1);
        vm.expectRevert("LSS: Report solved negatively");
        lssStaking.stakerClaim(2);
        vm.stopPrank();
    }

    function testStakeRewardsClaimVerifyReward()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        stakeOnReport(1, 5, 1 hours);
        stakeOnReport(2, 5, 1 hours);

        solveReportPositively(1);
        solveReportPositively(2);

        for (uint256 i = 0; i < stakers.length; i++) {
            vm.startPrank(stakers[i]);
            assertGt(lssStaking.stakerClaimableAmount(1), 0);
            assertGt(lssStaking.stakerClaimableAmount(2), 0);
            vm.stopPrank();
        }
    }

    function testStakeRewardsClaimTwice()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        stakeOnReport(1, 5, 1 hours);
        stakeOnReport(2, 5, 1 hours);

        solveReportPositively(1);
        solveReportPositively(2);

        vm.warp(block.timestamp + settlementPeriod + 1 minutes);

        claimStakeOnReport(1);
        claimStakeOnReport(2);

        vm.startPrank(stakers[0]);
        vm.expectRevert("LSS: You already claimed");
        lssStaking.stakerClaim(1);
        vm.expectRevert("LSS: You already claimed");
        lssStaking.stakerClaim(2);
        vm.stopPrank();
    }
}
