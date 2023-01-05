// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./ILosslessExtensionCore.sol";

interface ILosslessExtensibleWrappedERC20 is ICoreExtension {
    function supportsInterface(bytes4 interfaceId)
        external
        view
        override
        returns (bool);

    function registerExtension(address extension) external override;

    function unregisterExtension(address extension) external override;

    function setAdmin(address _admin) external;
}
