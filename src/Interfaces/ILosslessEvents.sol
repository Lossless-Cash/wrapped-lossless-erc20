// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILosslessEvents {
    event NewAdmin(address indexed _newAdmin);
    event NewRecoveryAdminProposal(address indexed _candidate);
    event NewRecoveryAdmin(address indexed _newAdmin);
    event LosslessTurnOffProposal(uint256 _turnOffDate);
    event LosslessOff();
    event LosslessOn();
    event UnwrappingDelayUpdate(uint256 newDelay);
    event UnwrapRequested(address indexed account, uint256 amount);
    event UnwrapCompleted(
        address indexed from,
        address indexed to,
        uint256 amount
    );
}
