// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "openzeppelin/contracts/token/ERC20/IERC20.sol";
import "openzeppelin/contracts/token/ERC20/extensions/ERC20Wrapper.sol";

import "WERC20e/ExtensibleWrappedERC20.sol";
import "WERC20e/Interfaces/IBurnExtension.sol";
import "WERC20e/Interfaces/ITransfersExtension.sol";
import "WERC20e/Interfaces/IMintExtension.sol";

import "./Interfaces/IHackMitigationExtension.sol";

contract LosslessWrappedERC20Extensible is WrappedERC20Extensible {
    address public hackMitigationExtension;

    constructor(
        IERC20 _underlyingToken,
        string memory _name,
        string memory _symbol,
        address _admin
    ) WrappedERC20Extensible(_underlyingToken, _name, _symbol, _admin) {}

    event HackMitigationExtensionRegistered(address hackExtensionAddress);

    /// @notice Determines whether the contract implements the given interface.
    /// @param interfaceId The interface identifier to check.
    /// @return bool Whether the contract implements the given interface.
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(WrappedERC20Extensible)
        returns (bool)
    {
        return
            interfaceId == type(ExtensionCore).interfaceId ||
            super.supportsInterface(interfaceId);
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
}
