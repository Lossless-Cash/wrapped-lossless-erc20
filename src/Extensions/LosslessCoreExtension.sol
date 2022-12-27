// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin/contracts/utils/introspection/IERC165.sol";
import "openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "openzeppelin/contracts/token/ERC20/ERC20.sol";

import "lossless-v3/Interfaces/ILosslessController.sol";

import "wLERC20/Interfaces/ILosslessCoreExtension.sol";
import "wLERC20/Interfaces/ILosslessExtensibleWrappedERC20.sol";

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

    function getLosslessController() public view returns (address) {
        return address(lossless);
    }

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

    function setLosslessAdmin(address newAdmin)
        external
        override
        onlyRecoveryAdmin
    {
        require(newAdmin != admin, "LERC20: Cannot set same address");
        emit NewAdmin(newAdmin);
        admin = newAdmin;
    }

    function transferRecoveryAdminOwnership(address candidate, bytes32 keyHash)
        external
        override
        onlyRecoveryAdmin
    {
        recoveryAdminCandidate = candidate;
        recoveryAdminKeyHash = keyHash;
        emit NewRecoveryAdminProposal(candidate);
    }

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

    function proposeLosslessTurnOff() external override onlyRecoveryAdmin {
        require(
            losslessTurnOffTimestamp == 0,
            "LERC20: TurnOff already proposed"
        );
        require(isLosslessOn, "LERC20: Lossless already off");
        losslessTurnOffTimestamp = block.timestamp + timelockPeriod;
        emit LosslessTurnOffProposal(losslessTurnOffTimestamp);
    }

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

    function executeLosslessTurnOn() external override onlyRecoveryAdmin {
        require(!isLosslessOn, "LERC20: Lossless already on");
        losslessTurnOffTimestamp = 0;
        isLosslessOn = true;
        emit LosslessOn();
    }

    function getAdmin() public view virtual returns (address) {
        return admin;
    }

    function setBeforeTransfer(address creator) external override {
        require(
            ERC165Checker.supportsInterface(
                creator,
                type(ILosslessExtensibleWrappedERC20).interfaceId
            ),
            "LSS: Creator must implement IERC20WrappedCore"
        );
        ILosslessExtensibleWrappedERC20(creator).setBeforeTransferExtension();
    }

    function setLosslessCoreExtension(address creator) external {
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

    function extensionBeforeTransfer(address recipient, uint256 amount)
        external
        override
    {
        if (isLosslessOn) {
            lossless.beforeTransfer(msg.sender, recipient, amount);
        }
    }

    function extensionBeforeTransferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override {
        if (isLosslessOn) {
            lossless.beforeTransfer(sender, recipient, amount);
        }
    }
}
