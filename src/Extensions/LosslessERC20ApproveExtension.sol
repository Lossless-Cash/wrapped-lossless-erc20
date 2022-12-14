// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin/contracts/utils/introspection/IERC165.sol";
import "openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "../Interfaces/ILosslessERC20ApproveExtension.sol";
import "../Interfaces/ILosslessExtensibleWrappedERC20.sol";

contract LosslessApproveTransferExtension is IERC20ApproveExtension {
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override
        returns (bool)
    {
        return interfaceId == type(IERC20ApproveExtension).interfaceId;
    }

    function setApproveTransfer(address creator) external override {
        require(
            ERC165Checker.supportsInterface(
                creator,
                type(ILosslessExtensibleWrappedERC20).interfaceId
            ),
            "LSS: Creator must implement IERC20WrappedCore"
        );
        ILosslessExtensibleWrappedERC20(creator).setApproveTransferExtension();
    }

    function approveTransfer(
        address operator,
        address from,
        address to
    ) external override returns (bool) {
        return true;
    }
}
