// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "WERC20e/Interfaces/IExtensibleWrappedERC20.sol";

interface ILosslessWrappedExtensibleERC20 is IExtensibleWrappedERC20 {
    function transferOutBlacklistedFunds(address[] calldata _from) external;
}
