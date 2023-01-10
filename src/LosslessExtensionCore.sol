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

    address internal _losslessCoreExtension;
    address internal _beforeTransferBase;
    address internal _afterTransferBase;
    address internal _beforeMintBase;
    address internal _afterMintBase;
    address internal _beforeBurnBase;
    address internal _afterBurnBase;

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
        _setLosslessCoreExtension(msg.sender);
    }

    function _setLosslessCoreExtension(address extension) internal {
        _losslessCoreExtension = extension;
        emit SetLosslessCoreExtension(extension);
    }

    /// @notice Get the Lossless Core Extension
    /// @return address of the extension contract
    function getLosslessCore() external view returns (address) {
        return _losslessCoreExtension;
    }

    // BEFORE TRANSFER EXTENSION
    /// @notice Set the Before Transfer Extension
    function setBeforeTransferExtension() external override requireExtension {
        _setBeforeTransferBase(msg.sender);
    }

    function _setBeforeTransferBase(address extension) internal {
        _beforeTransferBase = extension;
        emit BeforeTransferUpdated(extension);
    }

    function getBeforeTransfer() external view returns (address) {
        return _beforeTransferBase;
    }

    // AFTER TRANSFER EXTENSION
    /// @notice Set the After Transfer Extension
    function setAfterTransferExtension() external override requireExtension {
        _setAfterTransferBase(msg.sender);
    }

    function _setAfterTransferBase(address extension) internal {
        _afterTransferBase = extension;
        emit AfterTransferUpdated(extension);
    }

    function getAfterTransfer() external view returns (address) {
        return _afterTransferBase;
    }

    // BEFORE MINT EXTENSION
    /// @notice Set the Before Mint Extension
    function setBeforeMintExtension() external override {
        _setBeforeMintBase(msg.sender);
    }

    /// @notice Set the After Mint Extension
    function _setBeforeMintBase(address extension) internal {
        _beforeMintBase = extension;
        emit BeforeMintUpdated(extension);
    }

    function getBeforeMint() external view returns (address) {
        return _beforeMintBase;
    }

    // AFTER MINT EXTENSION

    /// @notice Set the After Mint Extension
    function setAfterMintExtension() external override requireExtension {
        _setAfterMintBase(msg.sender);
    }

    function _setAfterMintBase(address extension) internal {
        _afterMintBase = extension;
        emit AfterMintUpdated(extension);
    }

    function getAfterMint() external view returns (address) {
        return _afterMintBase;
    }

    // BEFORE BURN EXTENSION

    /// @notice Set the Before Burn Extension
    function setBeforeBurnExtension() external override requireExtension {
        _setBeforeBurnBase(msg.sender);
    }

    function _setBeforeBurnBase(address extension) internal {
        _beforeBurnBase = extension;
        emit BeforeBurnUpdated(extension);
    }

    function getBeforeBurn() external view returns (address) {
        return _beforeBurnBase;
    }

    // AFTER BURN EXTENSION

    // @notice Set the After Burn Extension
    function setAfterBurnExtension() external override requireExtension {
        _setAfterBurnBase(msg.sender);
    }

    function _setAfterBurnBase(address extension) internal {
        _afterBurnBase = extension;
        emit AfterBurnUpdated(extension);
    }

    function getAfterBurn() external view returns (address) {
        return _afterBurnBase;
    }
}
