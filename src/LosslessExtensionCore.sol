// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @author: manifold.xyz

import "openzeppelin/contracts/security/ReentrancyGuard.sol";
import "openzeppelin/contracts/utils/Strings.sol";
import "openzeppelin/contracts/utils/introspection/ERC165.sol";
import "openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "openzeppelin-upgradeable/contracts/utils/AddressUpgradeable.sol";

import "./Interfaces/ILosslessExtensionCore.sol";

abstract contract LosslessExtensionCore is
    ReentrancyGuard,
    ICoreExtension,
    ERC165
{
    using Strings for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;
    using AddressUpgradeable for address;

    EnumerableSet.AddressSet internal _extensions;
    EnumerableSet.AddressSet internal _blacklistedExtensions;

    mapping(uint256 => address) internal _tokensExtension;
    mapping(address => bool) internal _extensionApproveTransfers;

    address internal _approveTransferBase;

    bytes4 private constant _CREATOR_CORE_V1 = 0x28f10a21;

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(ICoreExtension).interfaceId ||
            interfaceId == _CREATOR_CORE_V1 ||
            super.supportsInterface(interfaceId);
    }

    function requireExtension() internal view {
        require(
            _extensions.contains(msg.sender),
            "LSS: Must be registered extension"
        );
    }

    function requireNonBlacklist(address extension) internal view {
        require(
            !_blacklistedExtensions.contains(extension),
            "LSS: Extension blacklisted"
        );
    }

    function getExtensions()
        external
        view
        override
        returns (address[] memory extensions)
    {
        extensions = new address[](_extensions.length());
        for (uint256 i; i < _extensions.length(); ) {
            extensions[i] = _extensions.at(i);
            unchecked {
                ++i;
            }
        }
        return extensions;
    }

    function _registerExtension(address extension) internal {
        require(
            extension != address(this) && extension.isContract(),
            "LSS: Invalid"
        );
        emit ExtensionRegistered(extension, msg.sender);
        _extensions.add(extension);
    }

    function setApproveTransferExtension() external override {
        requireExtension();
        _setApproveTransferBase(msg.sender);
    }

    function _unregisterExtension(address extension) internal {
        emit ExtensionUnregistered(extension, msg.sender);
        _extensions.remove(extension);
    }

    function _blacklistExtension(address extension) internal {
        require(
            extension != address(0) && extension != address(this),
            "LSS: Cannot blacklist yourself"
        );
        if (_extensions.contains(extension)) {
            emit ExtensionUnregistered(extension, msg.sender);
            _extensions.remove(extension);
        }
        if (!_blacklistedExtensions.contains(extension)) {
            emit ExtensionBlacklisted(extension, msg.sender);
            _blacklistedExtensions.add(extension);
        }
    }

    function _tokenExtension(uint256 tokenId)
        internal
        view
        returns (address extension)
    {
        extension = _tokensExtension[tokenId];

        require(extension != address(0), "LSS: No extension for token");
        require(
            !_blacklistedExtensions.contains(extension),
            "LSS: Extension blacklisted"
        );

        return extension;
    }

    function _setApproveTransferBase(address extension) internal {
        _approveTransferBase = extension;
        emit ApproveTransferUpdated(extension);
    }

    function getApproveTransfer() external view returns (address) {
        return _approveTransferBase;
    }
}
