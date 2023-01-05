// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "../utils/losslessEnv.t.sol";

contract StakeRewardsClaim is LosslessTestEnvironment {
    function testStakeRewardsClaimOnce()
        public
        withExtensibleCoreProtected
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        uint256 stakersBeforeBalanceExtensible = 0;
        uint256 stakersBeforeBalanceProtected = 0;
        uint256 stakersBeforeBalanceAdminless = 0;

        for (uint256 i = 0; i < stakers.length; i++) {
            stakersBeforeBalanceExtensible += wLERC20a.balanceOf(stakers[i]);
            stakersBeforeBalanceProtected += wLERC20p.balanceOf(stakers[i]);
            stakersBeforeBalanceAdminless += wLERC20e.balanceOf(stakers[i]);
        }

        stakeOnReport(1, 5, 1 hours);
        stakeOnReport(2, 5, 1 hours);
        stakeOnReport(3, 5, 1 hours);

        solveReportPositively(1);
        solveReportPositively(2);
        solveReportPositively(3);

        claimStakeOnReport(1);
        claimStakeOnReport(2);
        claimStakeOnReport(3);

        uint256 stakersAfterBalanceExtensible = 0;
        uint256 stakersAfterBalanceProtected = 0;
        uint256 stakersAfterBalanceAdminless = 0;

        for (uint256 i = 0; i < stakers.length; i++) {
            stakersAfterBalanceExtensible += wLERC20a.balanceOf(stakers[i]);
            stakersAfterBalanceProtected += wLERC20p.balanceOf(stakers[i]);
            stakersAfterBalanceAdminless += wLERC20e.balanceOf(stakers[i]);
        }

        assertGt(stakersAfterBalanceExtensible, stakersBeforeBalanceExtensible);
        assertGt(stakersAfterBalanceProtected, stakersBeforeBalanceProtected);
        assertGt(stakersAfterBalanceAdminless, stakersBeforeBalanceAdminless);
    }

    function testStakeRewardsClaimNegativeReport()
        public
        withExtensibleCoreProtected
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        stakeOnReport(1, 5, 1 hours);
        stakeOnReport(2, 5, 1 hours);
        stakeOnReport(3, 5, 1 hours);

        solveReportNegatively(1);
        solveReportNegatively(2);
        solveReportNegatively(3);

        vm.startPrank(stakers[0]);
        vm.expectRevert("LSS: Report solved negatively");
        lssStaking.stakerClaim(1);
        vm.expectRevert("LSS: Report solved negatively");
        lssStaking.stakerClaim(2);
        vm.expectRevert("LSS: Report solved negatively");
        lssStaking.stakerClaim(3);
        vm.stopPrank();
    }

    function testStakeRewardsClaimVerifyReward()
        public
        withExtensibleCoreProtected
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        stakeOnReport(1, 5, 1 hours);
        stakeOnReport(2, 5, 1 hours);
        stakeOnReport(3, 5, 1 hours);

        solveReportPositively(1);
        solveReportPositively(2);
        solveReportPositively(3);

        for (uint256 i = 0; i < stakers.length; i++) {
            vm.startPrank(stakers[i]);
            assertGt(lssStaking.stakerClaimableAmount(1), 0);
            assertGt(lssStaking.stakerClaimableAmount(2), 0);
            assertGt(lssStaking.stakerClaimableAmount(3), 0);
            vm.stopPrank();
        }
    }

    function testStakeRewardsClaimTwice()
        public
        withExtensibleCoreProtected
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        stakeOnReport(1, 5, 1 hours);
        stakeOnReport(2, 5, 1 hours);
        stakeOnReport(3, 5, 1 hours);

        solveReportPositively(1);
        solveReportPositively(2);
        solveReportPositively(3);

        claimStakeOnReport(1);
        claimStakeOnReport(2);
        claimStakeOnReport(3);

        vm.startPrank(stakers[0]);
        vm.expectRevert("LSS: You already claimed");
        lssStaking.stakerClaim(1);
        vm.expectRevert("LSS: You already claimed");
        lssStaking.stakerClaim(2);
        vm.expectRevert("LSS: You already claimed");
        lssStaking.stakerClaim(3);
        vm.stopPrank();
    }
}
