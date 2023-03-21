// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "../utils/losslessEnv.t.sol";

contract SettlementPeriod is LosslessTestEnvironment {
    function testSettlementPeriodLosslessTurnedOffUnlimitedTransfers()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
    {
        vm.startPrank(tokenOwner);
        wLERC20p.proposeLosslessTurnOff();

        vm.warp(block.timestamp + 1 hours);

        wLERC20p.executeLosslessTurnOff();

        wLERC20p.transfer(address(3000), 10);
        vm.stopPrank();

        vm.startPrank(address(3000));
        wLERC20p.transfer(address(3001), 2);
        wLERC20p.transfer(address(3002), 2);
        vm.stopPrank();
    }

    function testSettlementPeriodMultipleTransfer()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
    {
        vm.startPrank(tokenOwner);
        wLERC20p.transfer(address(3000), 10);
        vm.stopPrank();

        vm.startPrank(address(3000));

        wLERC20p.transfer(address(3001), 8);

        vm.warp(block.timestamp + (settlementPeriod / 2));

        vm.expectRevert("LSS: Transfers limit reached");
        wLERC20p.transfer(address(3001), 2);

        vm.stopPrank();
    }

    function testSettlementPeriodAllowTransferAfterSettlement()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
    {
        vm.startPrank(tokenOwner);
        wLERC20p.transfer(address(3000), 10);
        vm.stopPrank();

        vm.startPrank(address(3000));

        wLERC20p.transfer(address(3001), 8);

        vm.warp(block.timestamp + settlementPeriod + 1 minutes);

        wLERC20p.transfer(address(3001), 2);
        vm.stopPrank();
    }

    function testSettlementPeriodAllowTransferSettledAndPartOfUnsettled()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
    {
        vm.startPrank(tokenOwner);
        wLERC20p.transfer(address(3000), 10);
        vm.stopPrank();

        vm.startPrank(address(3000));

        wLERC20p.transfer(address(3001), 8);

        vm.stopPrank();

        vm.warp(block.timestamp + settlementPeriod + 1 minutes);

        vm.startPrank(tokenOwner);
        wLERC20p.transfer(address(3000), 10);
        vm.stopPrank();

        vm.startPrank(address(3000));
        wLERC20p.transfer(address(3001), 5);
        vm.stopPrank();
    }

    function testSettlementPeriodTransferToDexUnsettledUnderThreshold()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
    {
        vm.startPrank(tokenOwner);
        wLERC20p.transfer(address(3000), 10);
        vm.stopPrank();

        vm.startPrank(address(3000));

        wLERC20p.transfer(dex, 5);

        vm.stopPrank();
    }

    function testSettlementPeriodTransferToDexUnsettledAboveThreshold()
        public
        withProtectedWrappedToken
        withAdminlessProtectedWrappedToken
    {
        vm.startPrank(tokenOwner);
        wLERC20p.transfer(address(3000), 10);
        vm.stopPrank();

        vm.startPrank(address(3000));

        vm.expectRevert("LSS: Cannot transfer over the dex threshold");
        wLERC20p.transfer(dex, 6);

        vm.stopPrank();
    }
}
