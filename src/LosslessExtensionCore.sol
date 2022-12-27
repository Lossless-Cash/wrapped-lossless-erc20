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
    using Strings for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;
    using AddressUpgradeable for address;

    EnumerableSet.AddressSet internal _extensions;
    EnumerableSet.AddressSet internal _blacklistedExtensions;

    mapping(uint256 => address) internal _tokensExtension;
    mapping(address => bool) internal _extensionApproveTransfers;

    address internal _losslessCoreExtension;
    address internal _approveTransferBase;
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

    // LOSSLESS CORE EXTENSION
    function setLosslessCoreExtension() external {
        requireExtension();
        _setLosslessCoreExtension(msg.sender);
    }

    function _setLosslessCoreExtension(address extension) internal {
        _losslessCoreExtension = extension;
        //emit ApproveTransferUpdated(extension);
    }

    function getLosslessCore() external view returns (address) {
        return _losslessCoreExtension;
    }

    // APROVAL EXTENSION
    function setApproveTransferExtension() external override {
        requireExtension();
        _setApproveTransferBase(msg.sender);
    }

    function _setApproveTransferBase(address extension) internal {
        _approveTransferBase = extension;
        emit ApproveTransferUpdated(extension);
    }

    function getApproveTransfer() external view returns (address) {
        return _approveTransferBase;
    }

    // BEFORE TRANSFER EXTENSION

    function setBeforeTransferExtension() external override {
        requireExtension();
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

    function setAfterTransferExtension() external override {
        requireExtension();
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

    function setBeforeMintExtension() external override {
        requireExtension();
        _setBeforeMintBase(msg.sender);
    }

    function _setBeforeMintBase(address extension) internal {
        _beforeMintBase = extension;
        emit BeforeMintUpdated(extension);
    }

    function getBeforeMint() external view returns (address) {
        return _beforeMintBase;
    }

    // AFTER MINT EXTENSION

    function setAfterMintExtension() external override {
        requireExtension();
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

    function setBeforeBurnExtension() external override {
        requireExtension();
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

    function setAfterBurnExtension() external override {
        requireExtension();
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
