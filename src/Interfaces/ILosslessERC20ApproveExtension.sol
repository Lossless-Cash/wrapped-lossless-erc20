// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

//import "../Interfaces/ILosslessExtensionCore.sol";

interface IERC20ApproveExtension {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    function setApproveTransfer(address creator) external;

    function approveTransfer(
        address operator,
        address from,
        address to
    ) external returns (bool);
}
