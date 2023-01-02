// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./utils/losslessEnv.t.sol";

contract WrappedERC20Test is LosslessTestEnvironment {
    function testCoreExtensionSetUp() public lssCoreExtended {
        vm.prank(tokenOwner);
        wLERC20e.transfer(address(500), 500);

        vm.prank(address(500));
        wLERC20e.transfer(address(501), 500);
    }

    function testCoreExtensionMembersClaimAllParticipating()
        public
        lssCoreExtended
    {
        uint256[5] memory memberBalances;

        for (uint256 i = 0; i < committeeMembers.length; i++) {
            memberBalances[i] = wLERC20e.balanceOf(committeeMembers[i]);
        }

        uint256 reportId = generateReport(
            address(wLERC20e),
            maliciousActor,
            reporter,
            wLERC20e
        );

        solveReportPositively(reportId);
    }
}
