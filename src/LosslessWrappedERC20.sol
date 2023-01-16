// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "openzeppelin/contracts/token/ERC20/IERC20.sol";
import "openzeppelin/contracts/token/ERC20/extensions/ERC20Wrapper.sol";
import "lossless-v3/Interfaces/ILosslessController.sol";
import "./Interfaces/ILosslessWrappedERC20.sol";

/// @title Lossless Protected Wrapped ERC20
/// @notice This contract wraps an ERC20 with Lossless Core Protocol
contract LosslessWrappedERC20 is ERC20Wrapper, IWLERC20 {
    uint256 public constant VERSION = 1;

    address public recoveryAdmin;
    address private recoveryAdminCandidate;
    bytes32 private recoveryAdminKeyHash;
    address public admin;
    uint256 public timelockPeriod;
    uint256 public losslessTurnOffTimestamp;
    bool public isLosslessOn = true;
    ILssController public lossless;

    constructor(
        IERC20 _underlyingToken,
        string memory _name,
        string memory _symbol,
        address admin_,
        address recoveryAdmin_,
        uint256 timelockPeriod_,
        address lossless_
    ) ERC20(_name, _symbol) ERC20Wrapper(_underlyingToken) {
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
            lossless.beforeApprove(_msgSender(), spender, amount);
        }
        _;
    }

    modifier lssTransfer(address recipient, uint256 amount) {
        if (isLosslessOn) {
            lossless.beforeTransfer(_msgSender(), recipient, amount);
        }
        _;
    }

    modifier lssTransferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) {
        if (isLosslessOn) {
            lossless.beforeTransferFrom(
                _msgSender(),
                sender,
                recipient,
                amount
            );
        }
        _;
    }

    modifier lssIncreaseAllowance(address spender, uint256 addedValue) {
        if (isLosslessOn) {
            lossless.beforeIncreaseAllowance(_msgSender(), spender, addedValue);
        }
        _;
    }

    modifier lssDecreaseAllowance(address spender, uint256 subtractedValue) {
        if (isLosslessOn) {
            lossless.beforeDecreaseAllowance(
                _msgSender(),
                spender,
                subtractedValue
            );
        }
        _;
    }

    modifier onlyRecoveryAdmin() {
        require(
            _msgSender() == recoveryAdmin,
            "LERC20: Must be recovery admin"
        );
        _;
    }

    // --- LOSSLESS management ---
    /// @notice This function is for transfering out funds when a report is solved positively
    /// @param from blacklisted address
    function transferOutBlacklistedFunds(address[] calldata from)
        external
        override
    {
        require(isLosslessOn, "LSS: Lossless not active");
        require(
            _msgSender() == address(lossless),
            "LERC20: Only lossless contract"
        );

        uint256 fromLength = from.length;

        for (uint256 i = 0; i < fromLength; ) {
            uint256 fromBalance = balanceOf(from[i]);
            _transfer(from[i], address(lossless), fromBalance);
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
            _msgSender() == recoveryAdminCandidate,
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

    /// @notice This function corresponds to the regular transfer
    /// @dev This will call the lssTransfer modifier which perofrms all the necessary checks
    ///      with the Lossless controller
    /// @param recipient receiver address
    /// @param amount amount to transfer
    /// @return bool true if the transfer was successful
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override(ERC20)
        lssTransfer(recipient, amount)
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /// @notice This function corresponds to the regular approve
    /// @dev This will call the lssAprove modifier which perofrms all the necessary checks
    ///      with the Lossless controller
    /// @param spender sender address
    /// @param amount amount to transfer
    /// @return bool true if the transfer was approved successfully
    function approve(address spender, uint256 amount)
        public
        virtual
        override(ERC20)
        lssAprove(spender, amount)
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /// @notice This function corresponds to the regular transferFrom
    /// @dev This will call the lssTransferFrom modifier which perofrms all the necessary checks
    ///      with the Lossless controller
    /// @param sender sender address
    /// @param recipient receiver address
    /// @param amount amount to transfer
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    )
        public
        virtual
        override(ERC20)
        lssTransferFrom(sender, recipient, amount)
        returns (bool)
    {
        uint256 currentAllowance = allowance(sender, _msgSender());
        require(
            currentAllowance >= amount,
            "LERC20: transfer amount exceeds allowance"
        );
        _transfer(sender, recipient, amount);

        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    /// @notice This function corresponds to the regular increase allowance
    /// @dev This will call the lssIncreaseAllowance modifier which perofrms all the necessary checks
    ///      with the Lossless controller
    /// @param spender sender address
    /// @param addedValue amount to increase allowance
    /// @return bool true if the allwance increase was successful
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        override(ERC20)
        lssIncreaseAllowance(spender, addedValue)
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            allowance(_msgSender(), spender) + addedValue
        );
        return true;
    }

    /// @notice This function corresponds to the regular decrease allowance
    /// @dev This will call the lssDecreaseAllowance modifier which perofrms all the necessary checks
    ///      with the Lossless controller
    /// @param spender sender address
    /// @param subtractedValue amount to decrease allowance
    /// @return bool true if the allwance decrease was successful
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        override(ERC20)
        lssDecreaseAllowance(spender, subtractedValue)
        returns (bool)
    {
        uint256 currentAllowance = allowance(_msgSender(), spender);
        require(
            currentAllowance >= subtractedValue,
            "LERC20: decreased allowance below zero"
        );
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }
}
