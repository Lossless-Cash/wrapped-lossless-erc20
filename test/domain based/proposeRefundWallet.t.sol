// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "../utils/losslessEnv.t.sol";

contract ProposeRefundWallet is LosslessTestEnvironment {
    function testProposeRefundWalletNegativeResolve()
        public
        withExtensibleCoreProtected
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
        withReportsSolvedNegatively
    {
        vm.expectRevert("LSS: Report solved negatively");
        lssGovernance.proposeWallet(1, retrievalReceiver);
        vm.expectRevert("LSS: Report solved negatively");
        lssGovernance.proposeWallet(2, retrievalReceiver);
        vm.expectRevert("LSS: Report solved negatively");
        lssGovernance.proposeWallet(3, retrievalReceiver);
    }

    function testProposeRefundWalletPositiveResolve()
        public
        withExtensibleCoreProtected
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
        withReportsSolvedPositively
    {
        lssGovernance.proposeWallet(1, retrievalReceiver);
        lssGovernance.proposeWallet(2, retrievalReceiver);
        lssGovernance.proposeWallet(3, retrievalReceiver);
    }

    function testProposeRefundWalletPositiveResolveAnother()
        public
        withExtensibleCoreProtected
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
        withReportsSolvedPositively
    {
        lssGovernance.proposeWallet(1, retrievalReceiver);
        lssGovernance.proposeWallet(2, retrievalReceiver);
        lssGovernance.proposeWallet(3, retrievalReceiver);

        vm.expectRevert("LSS: Wallet already proposed");
        lssGovernance.proposeWallet(1, address(2));
        vm.expectRevert("LSS: Wallet already proposed");
        lssGovernance.proposeWallet(2, address(2));
        vm.expectRevert("LSS: Wallet already proposed");
        lssGovernance.proposeWallet(3, address(2));
    }

    function testProposeRefundWalletPositiveResolveZeroAddress()
        public
        withExtensibleCoreProtected
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
        withReportsSolvedPositively
    {
        vm.expectRevert("LSS: Wallet cannot ber zero adr");
        lssGovernance.proposeWallet(1, address(0));
        vm.expectRevert("LSS: Wallet cannot ber zero adr");
        lssGovernance.proposeWallet(2, address(0));
        vm.expectRevert("LSS: Wallet cannot ber zero adr");
        lssGovernance.proposeWallet(3, address(0));
    }

    function testProposeRefundWalletPositiveResolveAndClaim()
        public
        withExtensibleCoreProtected
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
        withReportsGenerated
        withReportsSolvedPositively
    {
        lssGovernance.proposeWallet(1, retrievalReceiver);
        lssGovernance.proposeWallet(2, retrievalReceiver);
        lssGovernance.proposeWallet(3, retrievalReceiver);

        vm.warp(9 days);

        uint256 balanceBeforeAdminless = wLERC20a.balanceOf(retrievalReceiver);
        uint256 balanceBeforeProtected = wLERC20p.balanceOf(retrievalReceiver);
        uint256 balanceBeforeExtensible = wLERC20e.balanceOf(retrievalReceiver);

        vm.startPrank(retrievalReceiver);
        lssGovernance.retrieveFunds(1);
        lssGovernance.retrieveFunds(2);
        lssGovernance.retrieveFunds(3);
        vm.stopPrank();

        uint256 balanceAfterAdminless = wLERC20a.balanceOf(retrievalReceiver);
        uint256 balanceAfterProtected = wLERC20p.balanceOf(retrievalReceiver);
        uint256 balanceAfterExtensible = wLERC20e.balanceOf(retrievalReceiver);

        assertGt(balanceAfterAdminless, balanceBeforeAdminless);
        assertGt(balanceAfterProtected, balanceBeforeProtected);
        assertGt(balanceAfterExtensible, balanceBeforeExtensible);
    }
}
