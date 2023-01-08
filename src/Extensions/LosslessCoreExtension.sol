// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin/contracts/utils/introspection/IERC165.sol";
import "openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "openzeppelin/contracts/token/ERC20/ERC20.sol";

import "lossless-v3/Interfaces/ILosslessController.sol";

import "wLERC20/Interfaces/ILosslessCoreExtension.sol";
import "wLERC20/Interfaces/ILosslessExtensibleWrappedERC20.sol";

/// @title Lossless Core Extension for Extendable Wrapped ERC20s
/// @notice This extension adds Lossless Core protocol to the wrapped token
contract LosslessCoreExtension is ILosslessCoreExtension {
    uint256 public constant VERSION = 1;

    address public protectedToken;
    address public recoveryAdmin;
    address private recoveryAdminCandidate;
    bytes32 private recoveryAdminKeyHash;
    address public admin;
    uint256 public timelockPeriod;
    uint256 public losslessTurnOffTimestamp;
    bool public isLosslessOn = true;
    ILssController public lossless;

    /// @notice This function is for checking if the contract allows an interface
    /// @param interfaceId Interface ID
    /// @return true if the interface id is accepted
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override
        returns (bool)
    {
        return interfaceId == type(ILosslessCoreExtension).interfaceId;
    }

    constructor(
        address admin_,
        address recoveryAdmin_,
        uint256 timelockPeriod_,
        address lossless_,
        address protectedToken_
    ) {
        protectedToken = protectedToken_;
        ILosslessExtensibleWrappedERC20(protectedToken).setAdmin(admin_);
        admin = admin_;
        recoveryAdmin = recoveryAdmin_;
        recoveryAdminCandidate = address(0);
        recoveryAdminKeyHash = "";
        timelockPeriod = timelockPeriod_;
        losslessTurnOffTimestamp = 0;
        lossless = ILssController(lossless_);
    }

    // --- LOSSLESS modifiers ---

    modifier lssAprove(address spender, uint256 amount) {
        if (isLosslessOn) {
            lossless.beforeApprove(msg.sender, spender, amount);
        }
        _;
    }

    modifier lssTransferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) {
        if (isLosslessOn) {
            lossless.beforeTransferFrom(msg.sender, sender, recipient, amount);
        }
        _;
    }

    modifier lssIncreaseAllowance(address spender, uint256 addedValue) {
        if (isLosslessOn) {
            lossless.beforeIncreaseAllowance(msg.sender, spender, addedValue);
        }
        _;
    }

    modifier lssDecreaseAllowance(address spender, uint256 subtractedValue) {
        if (isLosslessOn) {
            lossless.beforeDecreaseAllowance(
                msg.sender,
                spender,
                subtractedValue
            );
        }
        _;
    }

    modifier onlyRecoveryAdmin() {
        require(msg.sender == recoveryAdmin, "LERC20: Must be recovery admin");
        _;
    }

    // --- LOSSLESS management ---

    /// @notice This function is for getting the current lossless controller
    /// @return address lossless controller address
    function getLosslessController() public view returns (address) {
        return address(lossless);
    }

    /// @notice This function is for transfering out funds when a report is solved positively
    /// @param from blacklisted address
    function transferOutBlacklistedFunds(address[] calldata from) external {
        require(msg.sender == protectedToken, "LERC20: Only protected token");

        uint256 fromLength = from.length;

        for (uint256 i = 0; i < fromLength; ) {
            uint256 fromBalance = ERC20(protectedToken).balanceOf(from[i]);
            ERC20(protectedToken).transferFrom(
                from[i],
                address(lossless),
                fromBalance
            );
            unchecked {
                i++;
            }
        }
    }

    /// @notice This function is for setting the admin that interacts with lossless protocol
    /// @dev Only can be called by recovery admin
    /// @param newAdmin new admin address
    function setLosslessAdmin(address newAdmin)
        external
        override
        onlyRecoveryAdmin
    {
        require(newAdmin != admin, "LERC20: Cannot set same address");
        emit NewAdmin(newAdmin);
        admin = newAdmin;
    }

    /// @notice This function is for transfering the recovery admin role
    /// @dev Only can be called by recovery admin
    /// @param candidate New recovery admin address
    /// @param keyHash Key hash to accept transfer
    function transferRecoveryAdminOwnership(address candidate, bytes32 keyHash)
        external
        override
        onlyRecoveryAdmin
    {
        recoveryAdminCandidate = candidate;
        recoveryAdminKeyHash = keyHash;
        emit NewRecoveryAdminProposal(candidate);
    }

    /// @notice This function is for accepting the revoery admin ownership transfer
    /// @dev Only can be called by recovery admin
    /// @param key Key hash to accept transfer
    function acceptRecoveryAdminOwnership(bytes memory key) external override {
        require(
            msg.sender == recoveryAdminCandidate,
            "LERC20: Must be canditate"
        );
        require(keccak256(key) == recoveryAdminKeyHash, "LERC20: Invalid key");
        emit NewRecoveryAdmin(recoveryAdminCandidate);
        recoveryAdmin = recoveryAdminCandidate;
        recoveryAdminCandidate = address(0);
    }

    /// @notice This function is for proposing turning off lossless
    /// @dev Only can be called by recovery admin
    function proposeLosslessTurnOff() external override onlyRecoveryAdmin {
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
    function executeLosslessTurnOff() external override onlyRecoveryAdmin {
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
    function executeLosslessTurnOn() external override onlyRecoveryAdmin {
        require(!isLosslessOn, "LERC20: Lossless already on");
        losslessTurnOffTimestamp = 0;
        isLosslessOn = true;
        emit LosslessOn();
    }

    /// @notice This function is for getting the current admin
    /// @return address admin address
    function getAdmin() public view virtual returns (address) {
        return admin;
    }

    /// @notice This function will set the extension as the transfer base for the underlying token
    /// @dev This can only be called by the recovery admin
    /// @param creator underlying token address
    function setBeforeTransfer(address creator)
        external
        override
        onlyRecoveryAdmin
    {
        require(
            ERC165Checker.supportsInterface(
                creator,
                type(ILosslessExtensibleWrappedERC20).interfaceId
            ),
            "LSS: Creator must implement IERC20WrappedCore"
        );
        ILosslessExtensibleWrappedERC20(creator).setBeforeTransferExtension();
    }

    /// @notice This function will set the lossless core extension and the transfer base
    /// @dev This can only be called by the recovery admin
    /// @param creator underlying token address
    function setLosslessCoreExtension(address creator)
        external
        onlyRecoveryAdmin
    {
        require(
            ERC165Checker.supportsInterface(
                creator,
                type(ILosslessExtensibleWrappedERC20).interfaceId
            ),
            "LSS: Creator must implement IERC20WrappedCore"
        );
        ILosslessExtensibleWrappedERC20(creator).setLosslessCoreExtension();
        ILosslessExtensibleWrappedERC20(creator).setBeforeTransferExtension();
    }

    /// @notice This function executes the lossless controller before transfer
    /// @param recipient recipient address
    /// @param amount amount to transfer
    function extensionBeforeTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) external override {
        if (isLosslessOn) {
            lossless.beforeTransfer(sender, recipient, amount);
        }
    }

    /// @notice This function executes the lossless controller before transfer from
    /// @param sender sender address
    /// @param recipient recipient address
    /// @param amount amount to transfer
    function extensionBeforeTransferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override {
        if (isLosslessOn) {
            lossless.beforeTransfer(sender, recipient, amount);
        }
    }

    function balanceOf(address _adr) public returns (uint256) {
        return ERC20(protectedToken).balanceOf(_adr);
    }

    function extensionAfterTransfer(address recipient, uint256 amount)
        external
        override
    {}

    function extensionAfterTransferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override {}
}
