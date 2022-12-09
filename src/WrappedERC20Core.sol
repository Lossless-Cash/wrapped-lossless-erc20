// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./LosslessExtensionCore.sol";
import "./Interfaces/IWrappedERC20Core.sol";
import "./Interfaces/ILosslessERC20ApproveExtension.sol";

abstract contract WrappedERC20Core is LosslessExtensionCore, IERC20WrappedCore {
    uint256 public constant VERSION = 1;

    using EnumerableSet for EnumerableSet.AddressSet;

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(LosslessExtensionCore, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IERC20WrappedCore).interfaceId ||
            super.supportsInterface(interfaceId);
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
