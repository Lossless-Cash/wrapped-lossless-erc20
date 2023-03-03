// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "../Interfaces/ILosslessWrappedExtensibleERC20.sol";

import "extensible-wrapped-erc20/Interfaces/ITransferExtension.sol";
import "aegis-core-smart-contracts/interfaces/ILosslessAegisCore.sol";

/// @title Aegis Core Extension for Extendable Wrapped ERC20s
/// @notice This extension adds aegis interaction to an Extendable Wrapped ERC20s
contract AegisCoreExtension {
    address public protectedToken;
    address public admin;
    ILssAegisCore public aegis;

    event NewAegisUser(address, address);

    constructor(ILssAegisCore aegis_, address protectedToken_) {
        protectedToken = protectedToken_;
        admin = ILosslessWrappedExtensibleERC20(protectedToken_).admin();
        aegis = aegis_;
    }

    modifier onlyTokenAdmin() {
        require(msg.sender == admin, "LERC20: Must be recovery admin");
        _;
    }

    /// @notice This function is for getting the current admin
    /// @return address admin address
    function getAdmin() public view virtual returns (address) {
        return admin;
    }

    /// @notice This function will set the aegis core extension and the transfer base
    /// @dev This can only be called by the recovery admin
    function setHackMitigationExtension() external onlyTokenAdmin {
        require(
            ERC165Checker.supportsInterface(
                protectedToken,
                type(IExtensibleWrappedERC20).interfaceId
            ),
            "LSS: Creator must implement IERC20WrappedCore"
        );

        ICoreExtension(protectedToken).setBeforeTransferExtension();
        emit NewAegisUser(msg.sender, protectedToken);
    }

    /// @notice This function executes the lossless controller before transfer
    /// @param recipient recipient address
    /// @param amount amount to transfer
    function extensionBeforeTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) external {
        uint256 riskScore = aegis.getRiskScore(sender);
        riskScore += aegis.getRiskScore(recipient);
        require(riskScore < 1, "Aegis: High Risk transaction");
    }
}
