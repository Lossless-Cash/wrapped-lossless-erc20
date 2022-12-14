// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "openzeppelin/contracts/utils/introspection/IERC165.sol";

interface ICoreExtension is IERC165 {
    event ExtensionRegistered(
        address indexed extension,
        address indexed sender
    );
    event ExtensionUnregistered(
        address indexed extension,
        address indexed sender
    );
    event ExtensionBlacklisted(
        address indexed extension,
        address indexed sender
    );

    event ApproveTransferUpdated(address extension);

    event ExtensionApproveTransferUpdated(
        address indexed extension,
        bool enabled
    );

    function getExtensions() external view returns (address[] memory);

    function registerExtension(address extension) external;

    function unregisterExtension(address extension) external;

    function blacklistExtension(address extension) external;

    function setApproveTransferExtension() external;
}
