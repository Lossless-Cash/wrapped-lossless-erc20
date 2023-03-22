// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "../utils/losslessEnv.t.sol";

contract LosslessRewardsClaim is LosslessTestEnvironment {
    function testLosslessClaimWhenReportNotSolved()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        vm.expectRevert("LSS: Report solved negatively");
        lssGovernance.losslessClaim(1);
        vm.expectRevert("LSS: Report solved negatively");
        lssGovernance.losslessClaim(2);
    }

    function testLosslessClaimWhenReportSolvedNegatively()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        solveReportNegatively(1);
        vm.expectRevert("LSS: Report solved negatively");
        lssGovernance.losslessClaim(1);
        solveReportNegatively(2);
        vm.expectRevert("LSS: Report solved negatively");
        lssGovernance.losslessClaim(2);
    }

    function testLosslessClaimWhenReportSolvedPositively()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        solveReportPositively(1);
        lssGovernance.losslessClaim(1);
        solveReportPositively(2);
        lssGovernance.losslessClaim(2);
    }

    function testLosslessClaimBalanceIncrease()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        uint256 adminlessProtectedBalance = wLERC20a.balanceOf(address(this));
        uint256 protectedBalance = wLERC20p.balanceOf(address(this));

        solveReportPositively(1);
        lssGovernance.losslessClaim(1);
        solveReportPositively(2);
        lssGovernance.losslessClaim(2);

        uint256 afterAdminlessProtectedBalance = wLERC20a.balanceOf(
            address(this)
        );
        uint256 afterProtectedBalance = wLERC20p.balanceOf(address(this));

        assertGt(afterAdminlessProtectedBalance, adminlessProtectedBalance);
        assertGt(afterProtectedBalance, protectedBalance);
    }

    function testLosslessClaimSecondTimeRevert()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        solveReportPositively(1);
        lssGovernance.losslessClaim(1);
        solveReportPositively(2);
        lssGovernance.losslessClaim(2);

        vm.expectRevert("LSS: Already claimed");
        lssGovernance.losslessClaim(1);
        vm.expectRevert("LSS: Already claimed");
        lssGovernance.losslessClaim(2);
    }

    function testLosslessClaimNonLosslessAdmin()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
    {
        solveReportPositively(1);
        solveReportPositively(2);

        vm.startPrank(tokenOwner);
        vm.expectRevert("LSS: Must be admin");
        lssGovernance.losslessClaim(1);
        vm.expectRevert("LSS: Must be admin");
        lssGovernance.losslessClaim(2);
        vm.stopPrank();
    }
}
