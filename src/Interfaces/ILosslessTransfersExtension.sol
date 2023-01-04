// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

interface ILosslessTransferExtension {
    function extensionBeforeTransfer(address recipient, uint256 amount)
        external;

    function extensionBeforeTransferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external;

    function extensionAfterTransfer(address recipient, uint256 amount) external;

    function extensionAfterTransferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external;
}
