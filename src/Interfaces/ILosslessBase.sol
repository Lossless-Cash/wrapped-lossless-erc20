// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILosslessBase {
    function setLosslessAdmin(address _newAdmin) external;

    function transferRecoveryAdminOwnership(
        address _candidate,
        bytes32 _keyHash
    ) external;

    function acceptRecoveryAdminOwnership(bytes memory _key) external;

    function proposeLosslessTurnOff() external;

    function executeLosslessTurnOff() external;

    function executeLosslessTurnOn() external;

    event NewAdmin(address indexed _newAdmin);
    event NewRecoveryAdminProposal(address indexed _candidate);
    event NewRecoveryAdmin(address indexed _newAdmin);
    event LosslessTurnOffProposal(uint256 _turnOffDate);
    event LosslessOff();
    event LosslessOn();
}
