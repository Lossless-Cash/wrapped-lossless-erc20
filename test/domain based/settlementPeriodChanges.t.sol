// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "../utils/losslessEnv.t.sol";

contract SettlementPeriod is LosslessTestEnvironment {
    function testSettlementPeriodChangesProposalExecution()
        public
        withExtensibleCoreProtected
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
    {
        vm.startPrank(tokenOwner);
        lssController.proposeNewSettlementPeriod(
            ILERC20(address(wLERC20e)),
            1 minutes
        );
        lssController.proposeNewSettlementPeriod(
            ILERC20(address(wLERC20p)),
            1 minutes
        );

        vm.warp(settlementTimelock + 5 hours);

        lssController.executeNewSettlementPeriod(ILERC20(address(wLERC20p)));
        lssController.executeNewSettlementPeriod(ILERC20(address(wLERC20e)));

        vm.stopPrank();
    }

    function testSettlementPeriodChangesProposalExecutionBeforeTimelock()
        public
        withExtensibleCoreProtected
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
    {
        vm.startPrank(tokenOwner);
        lssController.proposeNewSettlementPeriod(
            ILERC20(address(wLERC20e)),
            1 minutes
        );
        lssController.proposeNewSettlementPeriod(
            ILERC20(address(wLERC20p)),
            1 minutes
        );

        vm.expectRevert("LSS: Time lock in progress");
        lssController.executeNewSettlementPeriod(ILERC20(address(wLERC20p)));
        vm.expectRevert("LSS: Time lock in progress");
        lssController.executeNewSettlementPeriod(ILERC20(address(wLERC20e)));

        vm.stopPrank();
    }

    function testSettlementPeriodChangesProposalByNonAdmin()
        public
        withExtensibleCoreProtected
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
    {
        vm.startPrank(address(3000));
        vm.expectRevert("LSS: Must be Token Admin");
        lssController.proposeNewSettlementPeriod(
            ILERC20(address(wLERC20e)),
            1 minutes
        );
        vm.expectRevert("LSS: Must be Token Admin");
        lssController.proposeNewSettlementPeriod(
            ILERC20(address(wLERC20p)),
            1 minutes
        );

        vm.stopPrank();
    }
}
