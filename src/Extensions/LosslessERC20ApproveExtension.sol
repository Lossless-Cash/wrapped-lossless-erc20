// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin/contracts/utils/introspection/IERC165.sol";
import "openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "../Interfaces/ILosslessERC20ApproveExtension.sol";
import "../Interfaces/ILosslessExtensibleWrappedERC20.sol";

contract LosslessApproveTransferExtension is IERC20ApproveExtension {
    //address[] registeredExtensions;

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override
        returns (bool)
    {
        return interfaceId == type(IERC20ApproveExtension).interfaceId;
    }

    function setApproveTransfer(address creator) external {
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
    /* 
    function blacklistExtension(address extension) external override {
        emit ExtensionBlacklisted(extension, msg.sender);
    }

    function getExtensions() external view override returns (address[] memory) {
        address[] memory extensions = registeredExtensions;
        return extensions;
    }

    function registerExtension(address extension) external {
        address[] storage extensions = registeredExtensions;
        extensions.push(extension);
        emit ExtensionRegistered(extension, msg.sender);
    }

    function setApproveTransferExtension() external {
        require(
            ERC165Checker.supportsInterface(
                msg.sender,
                type(ILosslessExtensibleWrappedERC20).interfaceId
            ),
            "LSS: Creator must implement IERC20WrappedCore"
        );
        LosslessExtensionCore(address(this)).setApproveTransferExtension();
        emit ApproveTransferUpdated(address(this));
    }

    function unregisterExtension(address extension) external {
        emit ExtensionUnregistered(extension, msg.sender);
    } */
}
