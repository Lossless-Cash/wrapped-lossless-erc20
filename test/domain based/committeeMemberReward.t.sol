// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "../utils/losslessEnv.t.sol";

contract CommitteeRewardsClaim is LosslessTestEnvironment {
    function testCommitteeRewardsClaimWhenNotResolved()
        public
        withExtensibleCoreProtected
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        for (uint256 i = 0; i < committeeMembers.length; i++) {
            vm.startPrank(committeeMembers[i]);
            vm.expectRevert("LSS: Report solved negatively");
            lssGovernance.claimCommitteeReward(1);
            vm.expectRevert("LSS: Report solved negatively");
            lssGovernance.claimCommitteeReward(2);
            vm.expectRevert("LSS: Report solved negatively");
            lssGovernance.claimCommitteeReward(3);
            vm.stopPrank();
        }
    }

    function testCommitteeRewardsClaimOnce()
        public
        withExtensibleCoreProtected
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
        withReportsSolvedPositively
    {
        for (uint256 i = 0; i < committeeMembers.length; i++) {
            uint256 balanceBeforeProtected = wLERC20p.balanceOf(
                committeeMembers[i]
            );
            uint256 balanceBeforeExtensible = wLERC20e.balanceOf(
                committeeMembers[i]
            );
            uint256 balanceBeforeAdminless = wLERC20a.balanceOf(
                committeeMembers[i]
            );
            vm.startPrank(committeeMembers[i]);
            lssGovernance.claimCommitteeReward(1);
            lssGovernance.claimCommitteeReward(2);
            lssGovernance.claimCommitteeReward(3);
            vm.stopPrank();

            assertGt(
                wLERC20p.balanceOf(committeeMembers[i]),
                balanceBeforeProtected
            );
            assertGt(
                wLERC20e.balanceOf(committeeMembers[i]),
                balanceBeforeExtensible
            );
            assertGt(
                wLERC20a.balanceOf(committeeMembers[i]),
                balanceBeforeAdminless
            );
        }
    }

    function testCommitteeRewardsClaimByNonMember()
        public
        withExtensibleCoreProtected
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
        withReportsSolvedPositively
    {
        vm.startPrank(address(3000));
        vm.expectRevert("LSS: Did not vote on report");
        lssGovernance.claimCommitteeReward(1);
        vm.expectRevert("LSS: Did not vote on report");
        lssGovernance.claimCommitteeReward(2);
        vm.expectRevert("LSS: Did not vote on report");
        lssGovernance.claimCommitteeReward(3);
        vm.stopPrank();
    }
}
