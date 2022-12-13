// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./ILosslessExtensionCore.sol";

interface ILosslessExtensibleWrappedERC20 is ICoreExtension {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    function registerExtension(address extension) external;

    function unregisterExtension(address extension) external;

    function blacklistExtension(address extension) external;
}
