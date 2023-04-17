// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import "./LosslessWrappedERC20.sol";

/// @title Lossless Protected Wrapped ERC20
/// @notice This contract wraps an ERC20 with Lossless Core Protocol
contract LosslessWrappedERC20Ownable is LosslessWrappedERC20 {
    address public recoveryAdmin;
    address private recoveryAdminCandidate;
    bytes32 private recoveryAdminKeyHash;
    address public admin;

    uint256 public timelockPeriod;
    uint256 public losslessTurnOffTimestamp;

    constructor(
        IERC20 _underlyingToken,
        string memory _name,
        string memory _symbol,
        address admin_,
        address recoveryAdmin_,
        uint256 timelockPeriod_,
        address lossless_,
        uint256 _unwrappingDelay
    )
        LosslessWrappedERC20(
            _underlyingToken,
            _name,
            _symbol,
            lossless_,
            _unwrappingDelay
        )
    {
        admin = admin_;
        recoveryAdmin = recoveryAdmin_;
        recoveryAdminCandidate = address(0);
        recoveryAdminKeyHash = "";
        timelockPeriod = timelockPeriod_;
        losslessTurnOffTimestamp = 0;
    }

    modifier onlyRecoveryAdmin() {
        require(
            _msgSender() == recoveryAdmin,
            "LERC20: Must be recovery admin"
        );
        _;
    }

    /// @notice This function is for setting the admin that interacts with lossless protocol
    /// @dev Only can be called by recovery admin
    /// @param newAdmin new admin address
    function setLosslessAdmin(address newAdmin) external onlyRecoveryAdmin {
        require(newAdmin != admin, "LERC20: Cannot set same address");
        emit NewAdmin(newAdmin);
        admin = newAdmin;
    }

    /// @notice This function is for transfering the recovery admin role
    /// @dev Only can be called by recovery admin
    /// @param candidate New recovery admin address
    /// @param keyHash Key hash to accept transfer
    function transferRecoveryAdminOwnership(
        address candidate,
        bytes32 keyHash
    ) external onlyRecoveryAdmin {
        recoveryAdminCandidate = candidate;
        recoveryAdminKeyHash = keyHash;
        emit NewRecoveryAdminProposal(candidate);
    }

    /// @notice This function is for accepting the recovery admin ownership transfer
    /// @dev Only can be called by recovery admin
    /// @param key Key hash to accept transfer
    function acceptRecoveryAdminOwnership(bytes memory key) external {
        require(
            _msgSender() == recoveryAdminCandidate,
            "LERC20: Must be candidate"
        );
        require(keccak256(key) == recoveryAdminKeyHash, "LERC20: Invalid key");
        emit NewRecoveryAdmin(recoveryAdminCandidate);
        recoveryAdmin = recoveryAdminCandidate;
        recoveryAdminCandidate = address(0);
    }

    /// @notice This function is for proposing turning off lossless
    /// @dev Only can be called by recovery admin
    function proposeLosslessTurnOff() external onlyRecoveryAdmin {
        require(
            losslessTurnOffTimestamp == 0,
            "LERC20: TurnOff already proposed"
        );
        require(isLosslessOn, "LERC20: Lossless already off");
        losslessTurnOffTimestamp = block.timestamp + timelockPeriod;
        emit LosslessTurnOffProposal(losslessTurnOffTimestamp);
    }

    /// @notice This function is for executing the lossless turn off
    /// @dev Only can be called by recovery admin and after the set period has passed
    function executeLosslessTurnOff() external onlyRecoveryAdmin {
        require(losslessTurnOffTimestamp != 0, "LERC20: TurnOff not proposed");
        require(
            losslessTurnOffTimestamp <= block.timestamp,
            "LERC20: Time lock in progress"
        );
        isLosslessOn = false;
        losslessTurnOffTimestamp = 0;
        emit LosslessOff();
    }

    /// @notice This function is for turning on lossless
    /// @dev Only can be called by recovery admin
    function executeLosslessTurnOn() external onlyRecoveryAdmin {
        require(!isLosslessOn, "LERC20: Lossless already on");
        losslessTurnOffTimestamp = 0;
        isLosslessOn = true;
        emit LosslessOn();
    }

    /// @notice This function sets a new unwrapping delay
    /// @dev Only can be called by recovery admin
    function setUnwrappingDelay(uint256 _newDelay) public onlyRecoveryAdmin {
        unwrappingDelay = _newDelay;
        emit UnwrappingDelayUpdate(_newDelay);
    }
}
