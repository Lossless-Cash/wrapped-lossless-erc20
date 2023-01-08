// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "../utils/losslessEnv.t.sol";

contract SecondReport is LosslessTestEnvironment {
    function testSecondReport()
        public
        withExtensibleCoreProtected
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        vm.startPrank(reporter);
        lssReporting.secondReport(1, address(9999));
        lssReporting.secondReport(2, address(9999));
        lssReporting.secondReport(3, address(9999));
        vm.stopPrank();
    }

    function testSecondReportZeroAddress()
        public
        withExtensibleCoreProtected
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        vm.startPrank(reporter);
        vm.expectRevert("LSS: Cannot report zero address");
        lssReporting.secondReport(1, address(0));
        vm.expectRevert("LSS: Cannot report zero address");
        lssReporting.secondReport(2, address(0));
        vm.expectRevert("LSS: Cannot report zero address");
        lssReporting.secondReport(3, address(0));
        vm.stopPrank();
    }

    function testSecondReportWhitelistedAddress()
        public
        withExtensibleCoreProtected
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        vm.startPrank(reporter);
        vm.expectRevert("LSS: Cannot report LSS protocol");
        lssReporting.secondReport(1, address(this));
        vm.expectRevert("LSS: Cannot report LSS protocol");
        lssReporting.secondReport(2, address(this));
        vm.expectRevert("LSS: Cannot report LSS protocol");
        lssReporting.secondReport(3, address(this));
        vm.stopPrank();
    }

    function testSecondReportNonExistantReport()
        public
        withExtensibleCoreProtected
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
        withExtensibleCoreProtected
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
        withExtensibleCoreProtected
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        vm.startPrank(address(998));
        vm.expectRevert("LSS: invalid reporter");
        lssReporting.secondReport(1, address(1000));
        vm.expectRevert("LSS: invalid reporter");
        lssReporting.secondReport(2, address(1000));
        vm.expectRevert("LSS: invalid reporter");
        lssReporting.secondReport(3, address(1000));
        vm.stopPrank();
    }

    function testSecondReportMoreThanOnce()
        public
        withExtensibleCoreProtected
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        vm.startPrank(reporter);
        lssReporting.secondReport(1, address(1000));
        lssReporting.secondReport(2, address(1000));
        lssReporting.secondReport(3, address(1000));

        vm.expectRevert("LSS: Another already submitted");
        lssReporting.secondReport(1, address(1000));
        vm.expectRevert("LSS: Another already submitted");
        lssReporting.secondReport(2, address(1000));
        vm.expectRevert("LSS: Another already submitted");
        lssReporting.secondReport(3, address(1000));
        vm.stopPrank();
    }

    function testSecondReportOnPositivelyResolvedReport()
        public
        withExtensibleCoreProtected
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
        vm.expectRevert("LSS: Report already solved");
        lssReporting.secondReport(3, address(1000));
        vm.stopPrank();
    }

    function testSecondReportOnNegativelyResolvedReport()
        public
        withExtensibleCoreProtected
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
        vm.expectRevert("LSS: Report already solved");
        lssReporting.secondReport(3, address(1000));
        vm.stopPrank();
    }

    function testSecondReportResolution()
        public
        withExtensibleCoreProtected
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        vm.startPrank(reporter);
        lssReporting.secondReport(1, address(1000));
        lssReporting.secondReport(2, address(1000));
        lssReporting.secondReport(3, address(1000));
        vm.stopPrank();

        solveReportPositively(1);
        solveReportPositively(2);
        solveReportPositively(3);
    }
}

/* 
describe('when generating another report', () => {


    describe('when solving a report with a second report', () => {
      it('should not revert', async () => {
        await
        env.lssReporting.connect(adr.reporter1)
          .secondReport(1, adr.maliciousActor2.address);

        await env.lssGovernance.connect(adr.lssAdmin).addCommitteeMembers([
          adr.member1.address,
          adr.member2.address,
          adr.member3.address,
          adr.member4.address,
          adr.member5.address]);

        await env.lssGovernance.connect(adr.lssAdmin).losslessVote(1, true);
        await env.lssGovernance.connect(adr.member1).committeeMemberVote(1, true);
        await env.lssGovernance.connect(adr.member2).committeeMemberVote(1, true);
        await env.lssGovernance.connect(adr.member3).committeeMemberVote(1, true);
        await env.lssGovernance.connect(adr.member4).committeeMemberVote(1, false);

        await expect(
          env.lssGovernance.connect(adr.lssAdmin).resolveReport(1),
        ).to.not.be.reverted;
      });
    });
  }); */
