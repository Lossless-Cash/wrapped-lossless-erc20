// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import "../utils/losslessEnv.t.sol";

contract ResolveReport is LosslessTestEnvironment {
    function testResolveReportPositively()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
        withReportsSolvedPositively
    {}

    function testResolveReportNegatively()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
        withReportsSolvedNegatively
    {}

    function testResolveReporTwice()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
        withReportsSolvedNegatively
    {
        vm.expectRevert("LSS: Report already solved");
        lssGovernance.resolveReport(1);
        vm.expectRevert("LSS: Report already solved");
        lssGovernance.resolveReport(2);
    }
}
