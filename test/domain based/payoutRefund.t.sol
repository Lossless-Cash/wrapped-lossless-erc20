// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "../utils/losslessEnv.t.sol";

contract PayoutRefund is LosslessTestEnvironment {
    function testPayoutRefundClaim()
        public
        withExtensibleCoreProtected
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
        withReportsSolvedNegatively
    {
        uint256 balanceBefore = lssToken.balanceOf(maliciousActor);

        vm.startPrank(maliciousActor);
        lssGovernance.retrieveCompensation();
        vm.stopPrank();

        uint256 balanceAfter = lssToken.balanceOf(maliciousActor);

        assertGt(balanceAfter, balanceBefore);
    }

    function testPayoutRefundClaimTwice()
        public
        withExtensibleCoreProtected
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
        withReportsSolvedNegatively
    {
        vm.startPrank(maliciousActor);
        lssGovernance.retrieveCompensation();

        vm.expectRevert("LSS: Already retrieved");
        lssGovernance.retrieveCompensation();
        vm.stopPrank();
    }

    function testPayoutRefundClaimByNonAfflicted()
        public
        withExtensibleCoreProtected
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
        withReportsSolvedNegatively
    {
        vm.startPrank(address(3001));
        vm.expectRevert("LSS: No retribution assigned");
        lssGovernance.retrieveCompensation();
        vm.stopPrank();
    }

    function testPayoutRefundClaimByNonLssGovernance()
        public
        withExtensibleCoreProtected
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
        withReportsSolvedNegatively
    {
        vm.startPrank(maliciousActor);
        vm.expectRevert("LSS: Lss SC only");
        lssReporting.retrieveCompensation(maliciousActor, 1000000);
        vm.stopPrank();
    }
}
