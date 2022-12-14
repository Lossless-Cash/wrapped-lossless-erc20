// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./utils/losslessEnv.t.sol";

contract WrappedERC20Test is LosslessTestEnvironment {
    function testExtensibleRegularTransfer() public withWrappedToken {
        vm.prank(tokenOwner);
        testERC20.approve(address(wLERC20), 10);

        vm.prank(tokenOwner);
        wLERC20.depositFor(tokenOwner, 10);

        assertEq(wLERC20.balanceOf(tokenOwner), 10);
    }

    function testExtensibleRegisterApproveExtension() public withWrappedToken {
        wLERC20.registerExtension(address(approveExtension));

        address[] memory extensions = wLERC20.getExtensions();

        assertEq(extensions[0], address(approveExtension));

        approveExtension.setApproveTransfer(address(wLERC20));

        vm.prank(tokenOwner);
        testERC20.approve(address(wLERC20), 10);

        vm.prank(tokenOwner);
        wLERC20.depositFor(tokenOwner, 10);

        assertEq(wLERC20.balanceOf(tokenOwner), 10);
    }

    function testExtensibleUnregisterApproveExtension()
        public
        withWrappedToken
    {
        wLERC20.registerExtension(address(approveExtension));

        address[] memory extensions = wLERC20.getExtensions();

        assertEq(extensions[0], address(approveExtension));

        approveExtension.setApproveTransfer(address(wLERC20));

        wLERC20.unregisterExtension(address(approveExtension));

        extensions = wLERC20.getExtensions();

        assertEq(extensions.length, 0);
    }

    function testExtensibleBlacklistApproveExtension() public withWrappedToken {
        wLERC20.blacklistExtension(address(approveExtension));

        vm.expectRevert(bytes("LSS: Extension blacklisted"));
        wLERC20.registerExtension(address(approveExtension));

        address[] memory extensions = wLERC20.getExtensions();

        assertEq(extensions.length, 0);
    }
}
