// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin/contracts/token/ERC20/IERC20.sol";
import "openzeppelin/contracts/token/ERC20/extensions/ERC20Wrapper.sol";
import "./Interfaces/ILosslessExtensibleWrappedERC20.sol";
import "./Interfaces/ILosslessERC20ApproveExtension.sol";
import "./LosslessExtensionCore.sol";

contract LosslessWrappedERC20Extensible is
    ERC20Wrapper,
    ILosslessExtensibleWrappedERC20,
    LosslessExtensionCore
{
    uint256 public constant VERSION = 1;

    constructor(
        IERC20 _underlyingToken,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) ERC20Wrapper(_underlyingToken) {}

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
        _approveTransfer(from, to);
    }

    function _mint(address to, uint256 amount) internal override(ERC20) {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount) internal override(ERC20) {
        super._burn(account, amount);
    }

    function registerExtension(address extension)
        external
        override(ICoreExtension, ILosslessExtensibleWrappedERC20)
    {
        requireNonBlacklist(extension);
        _registerExtension(extension);
    }

    function unregisterExtension(address extension)
        external
        override(ICoreExtension, ILosslessExtensibleWrappedERC20)
    {
        _unregisterExtension(extension);
    }

    function blacklistExtension(address extension)
        external
        override(ICoreExtension, ILosslessExtensibleWrappedERC20)
    {
        _blacklistExtension(extension);
    }

    function _approveTransfer(address from, address to) internal {
        if (_approveTransferBase != address(0)) {
            require(
                IERC20ApproveExtension(_approveTransferBase).approveTransfer(
                    msg.sender,
                    from,
                    to
                ),
                "LSS: Extension approval failure"
            );
        }
    }
}
