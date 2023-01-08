// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "../utils/losslessEnv.t.sol";

contract ReportGen is LosslessTestEnvironment {
    function testReportGen()
        public
        withExtensibleCoreProtected
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
    {
        lssToken.transfer(reporter, reportingAmount * 3);

        vm.startPrank(tokenOwner);
        wLERC20a.transfer(reporter, reportedAmount);
        wLERC20e.transfer(reporter, reportedAmount);
        wLERC20p.transfer(reporter, reportedAmount);
        vm.stopPrank();

        vm.warp(block.timestamp + settlementPeriod + 1);

        vm.startPrank(reporter);
        lssToken.approve(address(lssReporting), reportingAmount * 3);
        uint256 reportIdA = lssReporting.report(
            ILERC20(address(wLERC20a)),
            maliciousActor
        );
        uint256 reportIdP = lssReporting.report(
            ILERC20(address(wLERC20p)),
            maliciousActor
        );
        uint256 reportIdE = lssReporting.report(
            ILERC20(address(wLERC20e)),
            maliciousActor
        );
        vm.stopPrank();

        assertGt(reportIdA, 0);
        assertGt(reportIdP, 0);
        assertGt(reportIdE, 0);
    }

    function testReportGenTwice()
        public
        withExtensibleCoreProtected
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
    {
        lssToken.transfer(reporter, reportingAmount * 3);

        vm.startPrank(tokenOwner);
        wLERC20a.transfer(reporter, reportedAmount);
        wLERC20e.transfer(reporter, reportedAmount);
        wLERC20p.transfer(reporter, reportedAmount);
        vm.stopPrank();

        vm.warp(block.timestamp + settlementPeriod + 1);

        vm.startPrank(reporter);
        lssToken.approve(address(lssReporting), reportingAmount * 3);
        lssReporting.report(ILERC20(address(wLERC20a)), maliciousActor);
        lssReporting.report(ILERC20(address(wLERC20p)), maliciousActor);
        lssReporting.report(ILERC20(address(wLERC20e)), maliciousActor);

        vm.expectRevert("LSS: Report already exists");
        lssReporting.report(ILERC20(address(wLERC20a)), maliciousActor);
        vm.expectRevert("LSS: Report already exists");
        lssReporting.report(ILERC20(address(wLERC20p)), maliciousActor);
        vm.expectRevert("LSS: Report already exists");
        lssReporting.report(ILERC20(address(wLERC20e)), maliciousActor);
        vm.stopPrank();
    }

    function testReportGenZeroAddress()
        public
        withExtensibleCoreProtected
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
    {
        lssToken.transfer(reporter, reportingAmount * 3);

        vm.startPrank(tokenOwner);
        wLERC20a.transfer(reporter, reportedAmount);
        wLERC20e.transfer(reporter, reportedAmount);
        wLERC20p.transfer(reporter, reportedAmount);
        vm.stopPrank();

        vm.warp(block.timestamp + settlementPeriod + 1);

        vm.startPrank(reporter);
        lssToken.approve(address(lssReporting), reportingAmount * 3);

        vm.expectRevert("LSS: Cannot report zero address");
        lssReporting.report(ILERC20(address(wLERC20a)), address(0));
        vm.expectRevert("LSS: Cannot report zero address");
        lssReporting.report(ILERC20(address(wLERC20p)), address(0));
        vm.expectRevert("LSS: Cannot report zero address");
        lssReporting.report(ILERC20(address(wLERC20e)), address(0));
        vm.stopPrank();
    }

    function testReportGenWhitelistedAddress()
        public
        withExtensibleCoreProtected
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
    {
        lssToken.transfer(reporter, reportingAmount * 3);

        vm.startPrank(tokenOwner);
        wLERC20a.transfer(reporter, reportedAmount);
        wLERC20e.transfer(reporter, reportedAmount);
        wLERC20p.transfer(reporter, reportedAmount);
        vm.stopPrank();

        vm.warp(block.timestamp + settlementPeriod + 1);

        vm.startPrank(reporter);
        lssToken.approve(address(lssReporting), reportingAmount * 3);

        vm.expectRevert("LSS: Cannot report LSS protocol");
        lssReporting.report(ILERC20(address(wLERC20a)), address(this));
        vm.expectRevert("LSS: Cannot report LSS protocol");
        lssReporting.report(ILERC20(address(wLERC20p)), address(this));
        vm.expectRevert("LSS: Cannot report LSS protocol");
        lssReporting.report(ILERC20(address(wLERC20e)), address(this));
        vm.stopPrank();
    }

    function testReportGenDex()
        public
        withExtensibleCoreProtected
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
    {
        lssToken.transfer(reporter, reportingAmount * 3);

        vm.startPrank(tokenOwner);
        wLERC20a.transfer(reporter, reportedAmount);
        wLERC20e.transfer(reporter, reportedAmount);
        wLERC20p.transfer(reporter, reportedAmount);
        vm.stopPrank();

        vm.warp(block.timestamp + settlementPeriod + 1);

        vm.startPrank(reporter);
        lssToken.approve(address(lssReporting), reportingAmount * 3);

        vm.expectRevert("LSS: Cannot report Dex");
        lssReporting.report(ILERC20(address(wLERC20a)), dex);
        vm.expectRevert("LSS: Cannot report Dex");
        lssReporting.report(ILERC20(address(wLERC20p)), dex);
        vm.expectRevert("LSS: Cannot report Dex");
        lssReporting.report(ILERC20(address(wLERC20e)), dex);
        vm.stopPrank();
    }

    function testReportGenBlacklistingAddress()
        public
        withExtensibleCoreProtected
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        assertEq(lssController.blacklist(maliciousActor), true);
    }

    function testReportGenBlacklistingAddressPreventTransfer()
        public
        withExtensibleCoreProtected
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        assertEq(lssController.blacklist(maliciousActor), true);
        vm.startPrank(maliciousActor);
        vm.expectRevert("LSS: You cannot operate");
        wLERC20a.transfer(address(101), 1);
        vm.expectRevert("LSS: You cannot operate");
        wLERC20p.transfer(address(101), 1);
        vm.expectRevert("LSS: You cannot operate");
        wLERC20e.transfer(address(101), 1);
        vm.stopPrank();
    }

    function testReportGenExpiredLifetimeAllowResolution()
        public
        withExtensibleCoreProtected
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        vm.warp(block.timestamp + reportLifetime);

        vm.startPrank(address(300));
        lssGovernance.resolveReport(1);
        lssGovernance.resolveReport(2);
        lssGovernance.resolveReport(3);
        vm.stopPrank();
    }

    function testReportGenExpiredLifetimeGenerateReportAgain()
        public
        withExtensibleCoreProtected
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        vm.warp(block.timestamp + reportLifetime);

        vm.startPrank(address(300));
        lssGovernance.resolveReport(1);
        lssGovernance.resolveReport(2);
        lssGovernance.resolveReport(3);
        vm.stopPrank();

        lssToken.transfer(reporter, reportingAmount * 3);

        vm.startPrank(tokenOwner);
        wLERC20a.transfer(reporter, reportedAmount);
        wLERC20e.transfer(reporter, reportedAmount);
        wLERC20p.transfer(reporter, reportedAmount);
        vm.stopPrank();

        vm.warp(block.timestamp + settlementPeriod + 1);

        vm.startPrank(reporter);
        lssToken.approve(address(lssReporting), reportingAmount * 3);
        uint256 reportIdA = lssReporting.report(
            ILERC20(address(wLERC20a)),
            maliciousActor
        );
        uint256 reportIdP = lssReporting.report(
            ILERC20(address(wLERC20p)),
            maliciousActor
        );
        uint256 reportIdE = lssReporting.report(
            ILERC20(address(wLERC20e)),
            maliciousActor
        );
        vm.stopPrank();

        assertGt(reportIdA, 0);
        assertGt(reportIdP, 0);
        assertGt(reportIdE, 0);
    }
}
