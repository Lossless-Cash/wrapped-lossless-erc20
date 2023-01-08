// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "openzeppelin/contracts/token/ERC20/IERC20.sol";
import "openzeppelin/contracts/token/ERC20/extensions/ERC20Wrapper.sol";
import "./Interfaces/ILosslessExtensibleWrappedERC20.sol";
import "./Interfaces/ILosslessTransfersExtension.sol";
import "./Interfaces/ILosslessCoreExtension.sol";
import "./LosslessExtensionCore.sol";

contract LosslessWrappedERC20Extensible is
    ERC20Wrapper,
    ILosslessExtensibleWrappedERC20,
    LosslessExtensionCore
{
    uint256 public constant VERSION = 1;
    address public admin;

    constructor(
        IERC20 _underlyingToken,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) ERC20Wrapper(_underlyingToken) {}

    /// @notice Determines whether the contract implements the given interface.
    /// @param interfaceId The interface identifier to check.
    /// @return bool Whether the contract implements the given interface.
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ILosslessExtensibleWrappedERC20, LosslessExtensionCore)
        returns (bool)
    {
        return
            interfaceId == type(ILosslessExtensibleWrappedERC20).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /// @notice Registers the given extension.
    /// @dev Only extensions that are not blacklisted can be registered.
    /// @param extension The extension to be registered.
    function registerExtension(address extension)
        external
        override(ICoreExtension, ILosslessExtensibleWrappedERC20)
    {
        _registerExtension(extension);
    }

    /// @notice Unregisters the given extension.
    /// @param extension The extension to be unregistered.
    function unregisterExtension(address extension)
        external
        override(ICoreExtension, ILosslessExtensibleWrappedERC20)
    {
        _unregisterExtension(extension);
    }

    /// @notice Transfers the specified accounts' balances to the lossless controller.
    /// @dev Only the lossless controller is allowed to call this function.
    /// @param from An array of addresses whose balances should be transferred.
    function transferOutBlacklistedFunds(address[] calldata from) public {
        if (_losslessCoreExtension != address(0)) {
            require(
                msg.sender ==
                    ILosslessCoreExtension(_losslessCoreExtension)
                        .getLosslessController(),
                "LSS: Only lossless controller"
            );

            for (uint256 i = 0; i < from.length; ) {
                uint256 fromBalance = balanceOf(from[i]);
                _approve(from[i], address(_losslessCoreExtension), fromBalance);
                unchecked {
                    i++;
                }
            }

            ILosslessCoreExtension(_losslessCoreExtension)
                .transferOutBlacklistedFunds(from);
        } else {
            revert("LSS: Lossless Core Extension not registered");
        }
    }

    function setAdmin(address _admin) public {
        require(msg.sender != _losslessCoreExtension, "Only Core Extension");
        admin = _admin;
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20) {
        super._afterTokenTransfer(from, to, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20) {
        if (
            _beforeTransferBase != address(0) &&
            msg.sender != _beforeTransferBase
        ) {
            ILosslessTransferExtension(_beforeTransferBase)
                .extensionBeforeTransfer(from, to, amount);
        }
    }

    function _mint(address to, uint256 amount) internal override(ERC20) {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount) internal override(ERC20) {
        super._burn(account, amount);
    }
}
