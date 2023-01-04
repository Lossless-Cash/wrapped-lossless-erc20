// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

interface ILosslessMintExtension {
    function extensionBeforeMint(address to, uint256 amount) external;

    function extensionBeforeMintFrom(address from, uint256 amount) external;

    function extensionAfterMint(address to, uint256 amount) external;

    function extensionAfterMintFrom(address from, uint256 amount) external;
}
