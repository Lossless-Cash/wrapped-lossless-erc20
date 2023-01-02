// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "../utils/losslessEnv.t.sol";

contract LosslessRewardsClaim is LosslessTestEnvironment {
    function testLosslessClaimWhenReportNotSolved()
        public
        lssCoreExtended
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        vm.expectRevert("LSS: Report solved negatively");
        lssGovernance.losslessClaim(1);
        vm.expectRevert("LSS: Report solved negatively");
        lssGovernance.losslessClaim(2);
        vm.expectRevert("LSS: Report solved negatively");
        lssGovernance.losslessClaim(3);
    }

    function testLosslessClaimWhenReportSolvedNegatively()
        public
        lssCoreExtended
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        solveReportNegatively(1);
        vm.expectRevert("LSS: Report solved negatively");
        lssGovernance.losslessClaim(1);
        solveReportNegatively(2);
        vm.expectRevert("LSS: Report solved negatively");
        lssGovernance.losslessClaim(1);
        solveReportNegatively(3);
        vm.expectRevert("LSS: Report solved negatively");
        lssGovernance.losslessClaim(1);
    }

    function testLosslessClaimWhenReportSolvedPositively()
        public
        lssCoreExtended
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        solveReportPositively(1);
        lssGovernance.losslessClaim(1);
        solveReportPositively(2);
        lssGovernance.losslessClaim(2);
        solveReportPositively(3);
        lssGovernance.losslessClaim(3);
    }

    function testLosslessClaimBalanceIncrease()
        public
        lssCoreExtended
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        uint256 adminlessProtectedBalance = wLERC20ap.balanceOf(address(this));
        uint256 protectedBalance = wLERC20p.balanceOf(address(this));
        uint256 extensiblerotectedBalance = wLERC20e.balanceOf(address(this));

        solveReportPositively(1);
        lssGovernance.losslessClaim(1);
        solveReportPositively(2);
        lssGovernance.losslessClaim(2);
        solveReportPositively(3);
        lssGovernance.losslessClaim(3);

        uint256 afterAdminlessProtectedBalance = wLERC20ap.balanceOf(
            address(this)
        );
        uint256 afterProtectedBalance = wLERC20p.balanceOf(address(this));
        uint256 afterExtensiblerotectedBalance = wLERC20e.balanceOf(
            address(this)
        );

        assertGt(afterAdminlessProtectedBalance, adminlessProtectedBalance);
        assertGt(afterProtectedBalance, protectedBalance);
        assertGt(afterExtensiblerotectedBalance, extensiblerotectedBalance);
    }

    function testLosslessClaimSecondTimeRevert()
        public
        lssCoreExtended
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        solveReportPositively(1);
        lssGovernance.losslessClaim(1);
        solveReportPositively(2);
        lssGovernance.losslessClaim(2);
        solveReportPositively(3);
        lssGovernance.losslessClaim(3);

        vm.expectRevert("LSS: Already claimed");
        lssGovernance.losslessClaim(1);
        vm.expectRevert("LSS: Already claimed");
        lssGovernance.losslessClaim(2);
        vm.expectRevert("LSS: Already claimed");
        lssGovernance.losslessClaim(3);
    }

    function testLosslessClaimNonLosslessAdmin()
        public
        lssCoreExtended
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        solveReportPositively(1);
        solveReportPositively(2);
        solveReportPositively(3);

        vm.startPrank(tokenOwner);
        vm.expectRevert("LSS: Must be admin");
        lssGovernance.losslessClaim(1);
        vm.expectRevert("LSS: Must be admin");
        lssGovernance.losslessClaim(2);
        vm.expectRevert("LSS: Must be admin");
        lssGovernance.losslessClaim(3);
        vm.stopPrank();
    }
}
