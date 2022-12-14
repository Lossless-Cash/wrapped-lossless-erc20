// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./utils/losslessEnv.t.sol";

contract WrappedERC20Test is LosslessTestEnvironment {
    function testExtensibleRegularTransfer() public withExtensibleWrappedToken {
        vm.prank(tokenOwner);
        testERC20.approve(address(wLERC20e), 10);

        vm.prank(tokenOwner);
        wLERC20e.depositFor(tokenOwner, 10);

        assertEq(wLERC20e.balanceOf(tokenOwner), totalSupply - 100 + 10);
    }

    function testExtensibleRegisterApproveExtension()
        public
        withExtensibleWrappedToken
    {
        wLERC20e.registerExtension(address(approveExtension));

        address[] memory extensions = wLERC20e.getExtensions();

        assertEq(extensions[0], address(approveExtension));

        approveExtension.setApproveTransfer(address(wLERC20e));

        vm.prank(tokenOwner);
        testERC20.approve(address(wLERC20e), 10);

        vm.prank(tokenOwner);
        wLERC20e.depositFor(tokenOwner, 10);

        assertEq(wLERC20e.balanceOf(tokenOwner), totalSupply - 100 + 10);
    }

    function testExtensibleUnregisterApproveExtension()
        public
        withExtensibleWrappedToken
    {
        wLERC20e.registerExtension(address(approveExtension));

        address[] memory extensions = wLERC20e.getExtensions();

        assertEq(extensions[0], address(approveExtension));

        approveExtension.setApproveTransfer(address(wLERC20e));

        wLERC20e.unregisterExtension(address(approveExtension));

        extensions = wLERC20e.getExtensions();

        assertEq(extensions.length, 0);
    }

    function testExtensibleBlacklistApproveExtension()
        public
        withExtensibleWrappedToken
    {
        wLERC20e.blacklistExtension(address(approveExtension));

        vm.expectRevert(bytes("LSS: Extension blacklisted"));
        wLERC20e.registerExtension(address(approveExtension));

        address[] memory extensions = wLERC20e.getExtensions();

        assertEq(extensions.length, 0);
    }
}
