// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IWLERC20A {
    function transferOutBlacklistedFunds(address[] calldata _from) external;
}
