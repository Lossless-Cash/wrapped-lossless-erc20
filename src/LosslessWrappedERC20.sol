// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Wrapper.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "lossless-v3/Interfaces/ILosslessController.sol";

import "./Interfaces/ILosslessEvents.sol";

contract LosslessWrappedERC20 is
    ERC20Wrapper,
    ILosslessEvents,
    ReentrancyGuard
{
    using SafeERC20 for IERC20;

    bool public isLosslessOn = true;
    ILssController public lossless;

    uint256 public unwrappingDelay;

    struct Unwrapping {
        uint256 unwrappingAmount;
        uint256 unwrappingTimestamp;
    }

    mapping(address => Unwrapping) public unwrappingRequests;

    constructor(
        IERC20 _underlyingToken,
        string memory _name,
        string memory _symbol,
        address lossless_,
        uint256 _unwrappingDelay
    ) ERC20(_name, _symbol) ERC20Wrapper(_underlyingToken) {
        lossless = ILssController(lossless_);
        unwrappingDelay = _unwrappingDelay;
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

    // --- LOSSLESS management ---

    /// @notice Transfers the specified accounts' balances to the lossless contract.
    /// @dev Only the lossless contract is allowed to call this function.
    /// @param from An array of addresses whose balances should be transferred.
    function transferOutBlacklistedFunds(address[] calldata from) external {
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

    /// @notice Transfers `amount` tokens from the caller's account to `recipient`.
    /// @param recipient The address to which the tokens should be transferred.
    /// @param amount The amount of tokens to transfer.
    /// @return bool Whether the transfer was successful.
    function transfer(
        address recipient,
        uint256 amount
    )
        public
        virtual
        override(ERC20)
        lssTransfer(recipient, amount)
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /// @notice Approves `spender` to transfer `amount` tokens from the caller's account.
    /// @param spender The address of the contract that will be able to transfer the tokens.
    /// @param amount The amount of tokens that `spender` is approved to transfer.
    /// @return bool Whether the approval was successful.
    function approve(
        address spender,
        uint256 amount
    ) public virtual override(ERC20) lssAprove(spender, amount) returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /// @notice Transfers `amount` tokens from `sender` to `recipient` using the caller's allowance.
    /// @param sender The address of the account whose tokens will be transferred.
    /// @param recipient The address to which the tokens should be transferred.
    /// @param amount The amount of tokens to transfer.
    /// @return bool Whether the transfer was successful.
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

    /// @notice Increases the caller's allowance to `spender` by `addedValue`.
    /// @param spender The address of the contract that will be able to transfer the tokens.
    /// @param addedValue The amount by which the allowance should be increased.
    /// @return bool Whether the increase was successful.
    function increaseAllowance(
        address spender,
        uint256 addedValue
    )
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

    /// @notice Decreases the caller's allowance to `spender` by `subtractedValue`.
    /// @param spender The address of the contract that will no longer be able to transfer the tokens.
    /// @param subtractedValue The amount by which the allowance should be decreased.
    /// @return bool Whether the decrease was successful.
    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    )
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

    // LOSSLESS UNWRAPPING

    /// @notice This function places a withdraw request for an address
    /// @param amount Amount of tokens to unwrap
    function requestWithdraw(uint256 amount) public {
        require(
            amount <= balanceOf(_msgSender()),
            "LSS: Request exceeds balance"
        );

        Unwrapping storage unwrapping = unwrappingRequests[_msgSender()];

        require(unwrapping.unwrappingTimestamp == 0, "LSS: Pending withdraw");

        unwrapping.unwrappingAmount = amount;
        unwrapping.unwrappingTimestamp = block.timestamp + unwrappingDelay;

        emit UnwrapRequested(_msgSender(), amount);
    }

    /// @notice This function executes the unwrapping of tokens after a delay
    /// @param to Address to send the unwrapped tokens
    /// @param amount Amount of tokens to unwrap
    function withdrawTo(
        address to,
        uint256 amount
    ) public override nonReentrant returns (bool) {
        Unwrapping storage unwrapping = unwrappingRequests[_msgSender()];

        require(
            block.timestamp >= unwrapping.unwrappingTimestamp,
            "LSS: Unwrapping not ready yet"
        );

        require(
            amount <= unwrapping.unwrappingAmount,
            "LSS: Amount exceeds requested amount"
        );

        unwrapping.unwrappingAmount -= amount;

        if (unwrapping.unwrappingAmount == 0) {
            unwrapping.unwrappingTimestamp = 0;
        }

        _burn(_msgSender(), amount);
        SafeERC20.safeTransfer(underlying, to, amount);

        emit UnwrapCompleted(_msgSender(), to, amount);

        return true;
    }

    /// @notice This function cancels pending withdrawal request
    function cancelWithdrawRequest() public {
        Unwrapping storage unwrapping = unwrappingRequests[_msgSender()];

        require(
            unwrapping.unwrappingAmount > 0,
            "LSS: No active withdrawal request"
        );

        require(
            unwrapping.unwrappingTimestamp > block.timestamp,
            "LSS: Withdrawal request already executable"
        );

        unwrapping.unwrappingAmount = 0;
        unwrapping.unwrappingTimestamp = 0;

        emit WithdrawRequestCanceled(_msgSender());
    }
}
