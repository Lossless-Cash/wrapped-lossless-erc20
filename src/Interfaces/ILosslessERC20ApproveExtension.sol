// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

interface IERC20ApproveExtension {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    function setApproveTransfer(address creator) external;

    function extensionApproveTransfer(
        address operator,
        address from,
        address to
    ) external returns (bool);
}
