// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "../utils/losslessEnv.t.sol";

contract SecondReport is LosslessTestEnvironment {
    function testSecondReport()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        vm.startPrank(reporter);
        lssReporting.secondReport(1, address(9999));
        lssReporting.secondReport(2, address(9999));
        vm.stopPrank();
    }

    function testSecondReportZeroAddress()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        vm.startPrank(reporter);
        vm.expectRevert("LSS: Cannot report zero address");
        lssReporting.secondReport(1, address(0));
        vm.expectRevert("LSS: Cannot report zero address");
        lssReporting.secondReport(2, address(0));

        vm.stopPrank();
    }

    function testSecondReportWhitelistedAddress()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        vm.startPrank(reporter);
        vm.expectRevert("LSS: Cannot report LSS protocol");
        lssReporting.secondReport(1, address(this));
        vm.expectRevert("LSS: Cannot report LSS protocol");
        lssReporting.secondReport(2, address(this));

        vm.stopPrank();
    }

    function testSecondReportNonExistantReport()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        vm.startPrank(reporter);
        vm.expectRevert("LSS: invalid reporter");
        lssReporting.secondReport(99, address(1000));
        vm.stopPrank();
    }

    function testSecondReportOnExpiredReport()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        vm.warp(block.timestamp + reportLifetime + 1 hours);

        vm.startPrank(reporter);
        vm.expectRevert("LSS: report does not exists");
        lssReporting.secondReport(99, address(1000));
        vm.stopPrank();
    }

    function testSecondReportByOtherThanReporter()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        vm.startPrank(address(998));
        vm.expectRevert("LSS: invalid reporter");
        lssReporting.secondReport(1, address(1000));
        vm.expectRevert("LSS: invalid reporter");
        lssReporting.secondReport(2, address(1000));

        vm.stopPrank();
    }

    function testSecondReportMoreThanOnce()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        vm.startPrank(reporter);
        lssReporting.secondReport(1, address(1000));
        lssReporting.secondReport(2, address(1000));

        vm.expectRevert("LSS: Another already submitted");
        lssReporting.secondReport(1, address(1000));
        vm.expectRevert("LSS: Another already submitted");
        lssReporting.secondReport(2, address(1000));

        vm.stopPrank();
    }

    function testSecondReportOnPositivelyResolvedReport()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
        withReportsSolvedPositively
    {
        vm.startPrank(reporter);
        vm.expectRevert("LSS: Report already solved");
        lssReporting.secondReport(1, address(1000));
        vm.expectRevert("LSS: Report already solved");
        lssReporting.secondReport(2, address(1000));

        vm.stopPrank();
    }

    function testSecondReportOnNegativelyResolvedReport()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
        withReportsSolvedNegatively
    {
        vm.startPrank(reporter);
        vm.expectRevert("LSS: Report already solved");
        lssReporting.secondReport(1, address(1000));
        vm.expectRevert("LSS: Report already solved");
        lssReporting.secondReport(2, address(1000));

        vm.stopPrank();
    }

    function testSecondReportResolution()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        vm.startPrank(reporter);
        lssReporting.secondReport(1, address(1000));
        lssReporting.secondReport(2, address(1000));
        vm.stopPrank();

        solveReportPositively(1);
        solveReportPositively(2);
    }
}
