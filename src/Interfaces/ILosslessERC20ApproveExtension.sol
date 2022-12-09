// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../Interfaces/ILosslessExtensionCore.sol";

interface IERC20ApproveExtension is ICoreExtension {
    function setApproveTransfer(address creator) external;

    function approveTransfer(
        address operator,
        address from,
        address to
    ) external returns (bool);
}
