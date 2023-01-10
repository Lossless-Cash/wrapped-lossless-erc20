// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
    using EnumerableSet for EnumerableSet.AddressSet;
    using AddressUpgradeable for address;

    EnumerableSet.AddressSet internal _extensions;

    address public _losslessCoreExtension;
    address public _beforeTransferBase;
    address public _afterTransferBase;
    address public _beforeMintBase;
    address public _afterMintBase;
    address public _beforeBurnBase;
    address public _afterBurnBase;

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

    /// @notice Require that the caller is a registered extension
    /// @dev Reverts if the caller is not registered as an extension
    modifier requireExtension() {
        require(
            _extensions.contains(msg.sender),
            "LSS: Must be registered extension"
        );
        _;
    }

    /// @notice Get the registered extensions
    /// @return extensions Array of addresses of the registered extensions
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

    function _unregisterExtension(address extension) internal {
        emit ExtensionUnregistered(extension, msg.sender);
        _extensions.remove(extension);
    }

    // LOSSLESS CORE EXTENSION
    /// @notice Set the Lossless Core Extension
    function setLosslessCoreExtension() external requireExtension {
        _losslessCoreExtension = msg.sender;
        emit SetLosslessCoreExtension(msg.sender);
    }

    // BEFORE TRANSFER EXTENSION
    /// @notice Set the Before Transfer Extension
    function setBeforeTransferExtension() external requireExtension {
        _beforeTransferBase = msg.sender;
        emit BeforeTransferUpdated(msg.sender);
    }

    // AFTER TRANSFER EXTENSION
    /// @notice Set the After Transfer Extension
    function setAfterTransferExtension() external requireExtension {
        _afterTransferBase = msg.sender;
        emit AfterTransferUpdated(msg.sender);
    }

    // BEFORE MINT EXTENSION
    /// @notice Set the Before Mint Extension
    function setBeforeMintExtension() external requireExtension {
        _beforeMintBase = msg.sender;
        emit BeforeMintUpdated(msg.sender);
    }

    // AFTER MINT EXTENSION

    /// @notice Set the After Mint Extension
    function setAfterMintExtension() external requireExtension {
        _afterMintBase = msg.sender;
        emit AfterMintUpdated(msg.sender);
    }

    // BEFORE BURN EXTENSION

    /// @notice Set the Before Burn Extension
    function setBeforeBurnExtension() external requireExtension {
        _beforeBurnBase = msg.sender;
        emit BeforeBurnUpdated(msg.sender);
    }

    // AFTER BURN EXTENSION

    // @notice Set the After Burn Extension
    function setAfterBurnExtension() external requireExtension {
        _afterBurnBase = msg.sender;
        emit AfterBurnUpdated(msg.sender);
    }
}
