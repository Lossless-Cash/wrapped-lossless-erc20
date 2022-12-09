// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin/contracts/token/ERC20/IERC20.sol";
import "openzeppelin/contracts/token/ERC20/extensions/ERC20Wrapper.sol";
import "./Interfaces/IWrappedERC20Core.sol";
import "./WrappedERC20Core.sol";

contract LosslessWrappedERC20 is ERC20Wrapper, WrappedERC20Core {
    constructor(
        IERC20 _underlyingToken,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) ERC20Wrapper(_underlyingToken) {}

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

    function registerExtension(address extension) external override {
        requireNonBlacklist(extension);
        _registerExtension(extension);
    }

    function unregisterExtension(address extension) external override {
        _unregisterExtension(extension);
    }

    function blacklistExtension(address extension) external override {
        _blacklistExtension(extension);
    }
}
