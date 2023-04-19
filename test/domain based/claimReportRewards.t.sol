// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import "../utils/losslessEnv.t.sol";

contract ReporterRewardsClaim is LosslessTestEnvironment {
    function testReporterClaimBalanceIncrease()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        solveReportPositively(1);
        solveReportPositively(2);

        vm.warp(block.timestamp + settlementPeriod + 1);

        uint256 beforeBalanceAdminless = wLERC20a.balanceOf(address(reporter));
        uint256 beforeBalanceProtected = wLERC20p.balanceOf(address(reporter));

        vm.startPrank(reporter);
        lssReporting.reporterClaim(1);
        lssReporting.reporterClaim(2);
        vm.stopPrank();

        uint256 afterBalanceAdminless = wLERC20a.balanceOf(address(reporter));
        uint256 afterBalanceProtected = wLERC20p.balanceOf(address(reporter));

        assertGt(afterBalanceAdminless, beforeBalanceAdminless);
        assertGt(afterBalanceProtected, beforeBalanceProtected);
    }

    function testReporterClaimWhenReportSolvedPositively()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        solveReportPositively(1);
        solveReportPositively(2);

        vm.warp(block.timestamp + settlementPeriod + 1);

        vm.startPrank(reporter);
        lssReporting.reporterClaim(1);
        lssReporting.reporterClaim(2);
        vm.stopPrank();
    }

    function testReporterClaimWhenReportSolvedNegatively()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        solveReportNegatively(1);
        solveReportNegatively(2);

        vm.warp(block.timestamp + settlementPeriod + 1);

        vm.startPrank(reporter);
        vm.expectRevert("LSS: Report solved negatively");
        lssReporting.reporterClaim(1);
        vm.expectRevert("LSS: Report solved negatively");
        lssReporting.reporterClaim(2);
        vm.stopPrank();
    }

    function testReporterClaimWhenClaimingTwice()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        solveReportPositively(1);
        solveReportPositively(2);

        vm.warp(block.timestamp + settlementPeriod + 1);

        vm.startPrank(reporter);
        lssReporting.reporterClaim(1);
        lssReporting.reporterClaim(2);

        vm.expectRevert("LSS: You already claimed");
        lssReporting.reporterClaim(1);
        vm.expectRevert("LSS: You already claimed");
        lssReporting.reporterClaim(2);
        vm.stopPrank();
    }

    function testReporterClaimWhenNonReporterTriesToClaim()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        solveReportPositively(1);
        solveReportPositively(2);

        vm.warp(block.timestamp + settlementPeriod + 1);

        vm.startPrank(maliciousActor);
        vm.expectRevert("LSS: Only reporter");
        lssReporting.reporterClaim(1);
        vm.expectRevert("LSS: Only reporter");
        lssReporting.reporterClaim(2);
        vm.stopPrank();
    }
}
