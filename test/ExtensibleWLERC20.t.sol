// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./utils/losslessEnv.t.sol";

contract WrappedERC20Test is LosslessTestEnvironment {
    function testExtensibleRegularTransfer() public withExtensibleWrappedToken {
        vm.prank(tokenOwner);
        testERC20.approve(address(wLERC20e), 10);

        vm.prank(tokenOwner);
        wLERC20e.depositFor(tokenOwner, 10);

        assertEq(wLERC20e.balanceOf(tokenOwner), (totalSupply / 5) - 1100 + 10);
    }
}
