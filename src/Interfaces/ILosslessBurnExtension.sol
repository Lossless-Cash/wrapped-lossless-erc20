// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

interface ILosslessBurnExtension {
    function extensionBeforeBurn(address to, uint256 amount) external;

    function extensionBeforeBurnFrom(address from, uint256 amount) external;

    function extensionAfterBurn(address to, uint256 amount) external;

    function extensionAfterBurnFrom(address from, uint256 amount) external;
}
