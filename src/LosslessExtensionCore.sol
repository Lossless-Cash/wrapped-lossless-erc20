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

    address public beforeTransferBase;
    address public afterTransferBase;
    address public beforeTransferBaseFrom;
    address public afterTransferBaseFrom;
    address public beforeMintBase;
    address public afterMintBase;
    address public beforeBurnBase;
    address public afterBurnBase;
    address public beforeBurnBaseFrom;
    address public afterBurnBaseFrom;

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

    // BEFORE TRANSFER EXTENSION
    /// @notice Set the Before Transfer Extension
    function setBeforeTransferExtension() external requireExtension {
        beforeTransferBase = msg.sender;
        emit BeforeTransferUpdated(msg.sender);
    }

    // AFTER TRANSFER EXTENSION
    /// @notice Set the After Transfer Extension
    function setAfterTransferExtension() external requireExtension {
        afterTransferBase = msg.sender;
        emit AfterTransferUpdated(msg.sender);
    }

    // BEFORE TRANSFER EXTENSION
    /// @notice Set the Before Transfer Extension
    function setBeforeTransferFromExtension() external requireExtension {
        beforeTransferBaseFrom = msg.sender;
        emit BeforeTransferFromUpdated(msg.sender);
    }

    // AFTER TRANSFER EXTENSION
    /// @notice Set the After Transfer Extension
    function setAfterTransferFromExtension() external requireExtension {
        afterTransferBaseFrom = msg.sender;
        emit AfterTransferFromUpdated(msg.sender);
    }

    // BEFORE MINT EXTENSION
    /// @notice Set the Before Mint Extension
    function setBeforeMintExtension() external requireExtension {
        beforeMintBase = msg.sender;
        emit BeforeMintUpdated(msg.sender);
    }

    // AFTER MINT EXTENSION

    /// @notice Set the After Mint Extension
    function setAfterMintExtension() external requireExtension {
        afterMintBase = msg.sender;
        emit AfterMintUpdated(msg.sender);
    }

    // BEFORE BURN EXTENSION

    /// @notice Set the Before Burn Extension
    function setBeforeBurnExtension() external requireExtension {
        beforeBurnBase = msg.sender;
        emit BeforeBurnUpdated(msg.sender);
    }

    // AFTER BURN EXTENSION

    // @notice Set the After Burn Extension
    function setAfterBurnExtension() external requireExtension {
        afterBurnBase = msg.sender;
        emit AfterBurnUpdated(msg.sender);
    }

    /// @notice Set the Before Burn Extension
    function setBeforeBurnFromExtension() external requireExtension {
        beforeBurnBaseFrom = msg.sender;
        emit BeforeBurnFromUpdated(msg.sender);
    }

    // AFTER BURN EXTENSION

    // @notice Set the After Burn Extension
    function setAfterBurnFromExtension() external requireExtension {
        afterBurnBaseFrom = msg.sender;
        emit AfterBurnFromUpdated(msg.sender);
    }
}
