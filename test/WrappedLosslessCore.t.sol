// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/WrappedLosslessFactory.sol";
import "../src/LosslessWrappedERC20.sol";

contract WrappedLosslessFactoryTests is Test {
    WrappedLosslessFactory public wrappedCore;
    IERC20 public randomERC20;
    address public lssAdmin = address(1);

    function setUp() public {
        vm.prank(lssAdmin);
        wrappedCore = new WrappedLosslessFactory();
        randomERC20 = new ERC20("Some Token", "SOTO");
    }

    function testSetNumber() public {
        address owner = wrappedCore.owner();
        assertTrue(owner != address(0));
    }

    function testRegisterToken() public {
        vm.prank(lssAdmin);
        LosslessWrappedERC20 newWrappedToken = wrappedCore.registerToken(
            randomERC20,
            true
        );

        assertEq(newWrappedToken.name(), "Lossless Wrapped Some Token");
        assertEq(newWrappedToken.symbol(), "wLssSOTO");
    }
}
