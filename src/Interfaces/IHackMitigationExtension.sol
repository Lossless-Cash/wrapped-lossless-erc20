// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "wLERC20/Interfaces/ILosslessTransfersExtension.sol";

interface IHackMitigationExtension is ILosslessTransferExtension {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    function transferOutBlacklistedFunds(address[] calldata _from) external;

    function setLosslessAdmin(address _newAdmin) external;

    function transferRecoveryAdminOwnership(
        address _candidate,
        bytes32 _keyHash
    ) external;

    function acceptRecoveryAdminOwnership(bytes memory _key) external;

    function proposeLosslessTurnOff() external;

    function executeLosslessTurnOff() external;

    function executeLosslessTurnOn() external;

    function getLosslessController() external returns (address);

    event NewAdmin(address indexed _newAdmin);
    event NewRecoveryAdminProposal(address indexed _candidate);
    event NewRecoveryAdmin(address indexed _newAdmin);
    event LosslessTurnOffProposal(uint256 _turnOffDate);
    event LosslessOff();
    event LosslessOn();
}
