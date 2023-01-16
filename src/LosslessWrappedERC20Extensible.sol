// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "openzeppelin/contracts/token/ERC20/IERC20.sol";
import "openzeppelin/contracts/token/ERC20/extensions/ERC20Wrapper.sol";
import "./Interfaces/ILosslessExtensibleWrappedERC20.sol";
import "./Interfaces/ILosslessTransfersExtension.sol";
import "./Interfaces/ILosslessMintExtension.sol";
import "./Interfaces/ILosslessBurnExtension.sol";
import "./Interfaces/IHackMitigationExtension.sol";
import "./LosslessExtensionCore.sol";

contract LosslessWrappedERC20Extensible is
    ERC20Wrapper,
    ILosslessExtensibleWrappedERC20,
    LosslessExtensionCore
{
    uint256 public constant VERSION = 1;
    address public admin;
    address public hackMitigationExtension;

    constructor(
        IERC20 _underlyingToken,
        string memory _name,
        string memory _symbol,
        address _admin
    ) ERC20(_name, _symbol) ERC20Wrapper(_underlyingToken) {
        admin = _admin;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "LSS: Only admin");
        _;
    }

    event HackMitigationExtensionRegistered(address hackExtensionAddress);

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
        onlyAdmin
    {
        _registerExtension(extension);
    }

    /// @notice Unregisters the given extension.
    /// @param extension The extension to be unregistered.
    function unregisterExtension(address extension)
        external
        override(ICoreExtension, ILosslessExtensibleWrappedERC20)
        onlyAdmin
    {
        _unregisterExtension(extension);
    }

    /// @notice Transfers the specified accounts' balances to the lossless controller.
    /// @dev Only the lossless controller is allowed to call this function.
    /// @param from An array of addresses whose balances should be transferred.
    function transferOutBlacklistedFunds(address[] calldata from) public {
        if (hackMitigationExtension != address(0)) {
            require(
                msg.sender ==
                    IHackMitigationExtension(hackMitigationExtension)
                        .getLosslessController(),
                "LSS: Only lossless controller"
            );

            for (uint256 i = 0; i < from.length; ) {
                uint256 fromBalance = balanceOf(from[i]);
                _approve(
                    from[i],
                    address(hackMitigationExtension),
                    fromBalance
                );
                unchecked {
                    i++;
                }
            }

            IHackMitigationExtension(hackMitigationExtension)
                .transferOutBlacklistedFunds(from);
        } else {
            revert("LSS: Lossless Core Extension not registered");
        }
    }

    function setHackMitigationExtension(address _adr) public onlyAdmin {
        hackMitigationExtension = _adr;
        emit HackMitigationExtensionRegistered(_adr);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20) {
        if (
            beforeTransferBase != address(0) && msg.sender != beforeTransferBase
        ) {
            ILosslessTransferExtension(beforeTransferBase)
                .extensionBeforeTransfer(from, to, amount);
        }
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        if (
            afterTransferBase != address(0) && msg.sender != afterTransferBase
        ) {
            ILosslessTransferExtension(afterTransferBase)
                .extensionAfterTransfer(from, to, amount);
        }
    }

    function _beforeTokenTransferFrom(
        address from,
        address to,
        uint256 amount
    ) internal {
        if (
            beforeTransferBaseFrom != address(0) &&
            msg.sender != beforeTransferBaseFrom
        ) {
            ILosslessTransferExtension(beforeTransferBaseFrom)
                .extensionBeforeTransferFrom(from, to, amount);
        }
    }

    function _afterTokenTransferFrom(
        address from,
        address to,
        uint256 amount
    ) internal {
        if (
            afterTransferBaseFrom != address(0) &&
            msg.sender != afterTransferBaseFrom
        ) {
            ILosslessTransferExtension(afterTransferBaseFrom)
                .extensionAfterTransferFrom(from, to, amount);
        }
    }

    function _beforeMint(address to, uint256 amount) internal {
        if (beforeMintBase != address(0) && msg.sender != beforeMintBase) {
            ILosslessMintExtension(beforeMintBase).extensionBeforeMint(
                to,
                amount
            );
        }
    }

    function _afterMint(address to, uint256 amount) internal {
        if (afterMintBase != address(0) && msg.sender != afterMintBase) {
            ILosslessMintExtension(afterMintBase).extensionAfterMint(
                to,
                amount
            );
        }
    }

    function _beforeBurn(address to, uint256 amount) internal {
        if (beforeBurnBase != address(0) && msg.sender != beforeBurnBase) {
            ILosslessBurnExtension(beforeBurnBase).extensionBeforeBurn(
                to,
                amount
            );
        }
    }

    function _afterBurn(address to, uint256 amount) internal {
        if (afterBurnBase != address(0) && msg.sender != afterBurnBase) {
            ILosslessBurnExtension(afterBurnBase).extensionAfterBurn(
                to,
                amount
            );
        }
    }

    function _beforeBurnFrom(address to, uint256 amount) internal {
        if (
            beforeBurnBaseFrom != address(0) && msg.sender != beforeBurnBaseFrom
        ) {
            ILosslessBurnExtension(beforeBurnBaseFrom).extensionBeforeBurnFrom(
                to,
                amount
            );
        }
    }

    function _afterBurnFrom(address to, uint256 amount) internal {
        if (
            afterBurnBaseFrom != address(0) && msg.sender != afterBurnBaseFrom
        ) {
            ILosslessBurnExtension(afterBurnBaseFrom).extensionAfterBurnFrom(
                to,
                amount
            );
        }
    }

    function _mint(address to, uint256 amount) internal override(ERC20) {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount) internal override(ERC20) {
        super._burn(account, amount);
    }
}
