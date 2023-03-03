// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Wrapper.sol";
import "lossless-v3/Interfaces/ILosslessController.sol";
import "./Interfaces/ILosslessWrappedERC20Adminless.sol";


// This has some same issues that are in LosslessWrappedERC20.sol
// Not gonna repeat it
contract LosslessWrappedERC20Adminless is ERC20Wrapper, IWLERC20A {
    uint256 public constant VERSION = 1;

    address public admin;

    ILssController public lossless;

    uint256 unwrappingDelay;

    struct Unwrapping {
        bool hasRequest;
        uint256 unwrappingTimestamp;
        uint256 unwrappingAmount;
    }

    mapping(address => Unwrapping) private unwrappingRequests;

    constructor(
        IERC20 _underlyingToken,
        string memory _name,
        string memory _symbol,
        address lossless_,
        uint256 _unwrappingDelay
    ) ERC20(_name, _symbol) ERC20Wrapper(_underlyingToken) {
        admin = address(this);
        lossless = ILssController(lossless_);
        unwrappingDelay = _unwrappingDelay;
    }

    // --- LOSSLESS modifiers ---

    modifier lssAprove(address spender, uint256 amount) {
        lossless.beforeApprove(_msgSender(), spender, amount);
        _;
    }

    modifier lssTransfer(address recipient, uint256 amount) {
        lossless.beforeTransfer(_msgSender(), recipient, amount);
        _;
    }

    modifier lssTransferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) {
        lossless.beforeTransferFrom(_msgSender(), sender, recipient, amount);
        _;
    }

    modifier lssIncreaseAllowance(address spender, uint256 addedValue) {
        lossless.beforeIncreaseAllowance(_msgSender(), spender, addedValue);
        _;
    }

    modifier lssDecreaseAllowance(address spender, uint256 subtractedValue) {
        lossless.beforeDecreaseAllowance(
            _msgSender(),
            spender,
            subtractedValue
        );
        _;
    }

    // --- LOSSLESS management ---

    /// @notice Transfers the specified accounts' balances to the lossless contract.
    /// @dev Only the lossless contract is allowed to call this function.
    /// @param from An array of addresses whose balances should be transferred.
    function transferOutBlacklistedFunds(address[] calldata from)
        external
        override
    {
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

    /// @notice Approves `spender` to transfer `amount` tokens from the caller's account.
    /// @param spender The address of the contract that will be able to transfer the tokens.
    /// @param amount The amount of tokens that `spender` is approved to transfer.
    /// @return bool Whether the approval was successful.
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

    /// @notice Decreases the caller's allowance to `spender` by `subtractedValue`.
    /// @param spender The address of the contract that will no longer be able to transfer the tokens.
    /// @param subtractedValue The amount by which the allowance should be decreased.
    /// @return bool Whether the decrease was successful.
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

    // withdraw logic should be moved to separate contract and all the contract should inherit from it
    // This way we can prevent copy pasting this in each contract

    function requestWithdraw(uint256 amount) public {
        Unwrapping storage unwrapping = unwrappingRequests[msg.sender];

        require(unwrapping.hasRequest == false, "LSS: Request already set");

        unwrapping.unwrappingAmount = amount;
        unwrapping.unwrappingTimestamp = block.timestamp + unwrappingDelay;
        unwrapping.hasRequest = true;
    }

    function withdrawTo(address account, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        Unwrapping storage unwrapping = unwrappingRequests[msg.sender];

        require(unwrapping.hasRequest == true, "LSS: No request in place");

        require(
            block.timestamp >= unwrapping.unwrappingTimestamp,
            "LSS: Unwrapping not ready yet"
        );
        require(
            amount <= unwrapping.unwrappingAmount,
            "LSS: Amount exceed requested amount"
        );

        unwrapping.hasRequest = false;

        _burn(_msgSender(), amount);
        SafeERC20.safeTransfer(underlying, account, amount);

        return true;
    }
}
