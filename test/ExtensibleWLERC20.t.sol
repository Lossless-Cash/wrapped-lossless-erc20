// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/LosslessWrappedERC20Extensible.sol";
import "../src/LosslessWrappingFactory.sol";
import "../src/Extensions/LosslessERC20ApproveExtension.sol";
import "../src/Mocks/ERC20Mock.sol";
import "forge-std/console.sol";

contract WrappedERC20Test is Test {
    LosslessWrappedERC20Extensible public wrappedCore;
    WrappedLosslessFactory public losslessFactory;
    LosslessApproveTransferExtension public approveExtension;
    TestToken public testERC20;
    address tokenOwner = address(1);

    function setUp() public {
        losslessFactory = new WrappedLosslessFactory();
        approveExtension = new LosslessApproveTransferExtension();
        vm.prank(tokenOwner);
        testERC20 = new TestToken("Testing Token", "TEST", 100000000);
    }

    function testRegisterToken() public {
        LosslessWrappedERC20Extensible newWrappedToken = losslessFactory
            .registerToken(testERC20);

        assertEq(newWrappedToken.name(), "Lossless Wrapped Testing Token");
        assertEq(newWrappedToken.symbol(), "wLssTEST");
    }

    function tesRegularTransfer() public {
        vm.prank(tokenOwner);
        LosslessWrappedERC20Extensible newWrappedToken = losslessFactory
            .registerToken(testERC20);

        assertEq(newWrappedToken.name(), "Lossless Wrapped Testing Token");
        assertEq(newWrappedToken.symbol(), "wLssTEST");

        vm.prank(tokenOwner);
        testERC20.approve(address(newWrappedToken), 10);

        vm.prank(tokenOwner);
        newWrappedToken.depositFor(tokenOwner, 10);

        assertEq(newWrappedToken.balanceOf(tokenOwner), 10);
    }

    function testRegisterApproveExtension() public {
        vm.prank(tokenOwner);
        LosslessWrappedERC20Extensible newWrappedToken = losslessFactory
            .registerToken(testERC20);

        assertEq(newWrappedToken.name(), "Lossless Wrapped Testing Token");
        assertEq(newWrappedToken.symbol(), "wLssTEST");

        newWrappedToken.registerExtension(address(approveExtension));

        address[] memory extensions = newWrappedToken.getExtensions();

        assertEq(extensions[0], address(approveExtension));

        approveExtension.setApproveTransfer(address(newWrappedToken));

        vm.prank(tokenOwner);
        testERC20.approve(address(newWrappedToken), 10);

        vm.prank(tokenOwner);
        newWrappedToken.depositFor(tokenOwner, 10);

        assertEq(newWrappedToken.balanceOf(tokenOwner), 10);
    }

    function testUnregisterApproveExtension() public {
        vm.prank(tokenOwner);
        LosslessWrappedERC20Extensible newWrappedToken = losslessFactory
            .registerToken(testERC20);

        assertEq(newWrappedToken.name(), "Lossless Wrapped Testing Token");
        assertEq(newWrappedToken.symbol(), "wLssTEST");

        newWrappedToken.registerExtension(address(approveExtension));

        address[] memory extensions = newWrappedToken.getExtensions();

        assertEq(extensions[0], address(approveExtension));

        approveExtension.setApproveTransfer(address(newWrappedToken));

        newWrappedToken.unregisterExtension(address(approveExtension));

        extensions = newWrappedToken.getExtensions();

        assertEq(extensions.length, 0);
    }

    function testBlacklistApproveExtension() public {
        vm.prank(tokenOwner);
        LosslessWrappedERC20Extensible newWrappedToken = losslessFactory
            .registerToken(testERC20);

        assertEq(newWrappedToken.name(), "Lossless Wrapped Testing Token");
        assertEq(newWrappedToken.symbol(), "wLssTEST");

        newWrappedToken.blacklistExtension(address(approveExtension));

        vm.expectRevert(bytes("LSS: Extension blacklisted"));
        newWrappedToken.registerExtension(address(approveExtension));

        address[] memory extensions = newWrappedToken.getExtensions();

        assertEq(extensions.length, 0);
    }
}
