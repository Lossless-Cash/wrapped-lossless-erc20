// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./utils/losslessEnv.t.sol";

import "wLERC20/Extensions/LosslessCoreExtension.sol";

contract WrappedERC20Test is LosslessTestEnvironment {
    LosslessCoreExtension public coreExtension;

    modifier lssCoreExtended() {
        setUpTests();
        _;
    }

    function setUpTests() public {
        vm.startPrank(tokenOwner);
        wLERC20e = losslessFactory.registerExtensibleToken(testERC20);

        assertEq(wLERC20e.name(), "Lossless Extensible Wrapped Testing Token");
        assertEq(wLERC20e.symbol(), "wLTESTe");

        testERC20.approve(address(wLERC20e), testERC20.balanceOf(tokenOwner));
        wLERC20e.depositFor(
            address(tokenOwner),
            testERC20.balanceOf(tokenOwner) - 100
        );

        coreExtension = new LosslessCoreExtension(
            tokenOwner,
            tokenOwner,
            settlementTimelock,
            address(lssController)
        );

        wLERC20e.registerExtension(address(coreExtension));

        address[] memory extensions = wLERC20e.getExtensions();

        assertEq(extensions[0], address(coreExtension));

        coreExtension.setBeforeTransfer(address(wLERC20e));

        assertEq(wLERC20e.getBeforeTransfer(), address(coreExtension));

        vm.stopPrank();
    }

    function testCoreExtensionSetUp() public lssCoreExtended {
        vm.prank(tokenOwner);
        wLERC20e.transfer(address(500), 500);

        vm.prank(address(500));
        wLERC20e.transfer(address(501), 500);
    }
}
