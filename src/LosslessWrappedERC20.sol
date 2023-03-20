// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Wrapper.sol";
import "lossless-v3/Interfaces/ILosslessController.sol";

import "./Utils/LosslessUnwrapper.sol";
import "./Utils/LosslessBase.sol";

/// @title Lossless Protected Wrapped ERC20
/// @notice This contract wraps an ERC20 with Lossless Core Protocol
contract LosslessWrappedERC20 is ERC20Wrapper, LosslessUnwrapper, LosslessBase {
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
        ERC20(_name, _symbol)
        ERC20Wrapper(_underlyingToken)
        LosslessBase(admin_, recoveryAdmin_, timelockPeriod_, lossless_)
        LosslessUnwrapper(_unwrappingDelay, address(this))
    {}

    // --- LOSSLESS management ---
    /// @notice This function is for transfering out funds when a report is solved positively
    /// @param from blacklisted address
    function transferOutBlacklistedFunds(
        address[] calldata from
    ) external override {
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

    /// @notice This function corresponds to the regular transfer
    /// @dev This will call the lssTransfer modifier which perofrms all the necessary checks
    ///      with the Lossless controller
    /// @param recipient receiver address
    /// @param amount amount to transfer
    /// @return bool true if the transfer was successful
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

    /// @notice This function corresponds to the regular approve
    /// @dev This will call the lssAprove modifier which perofrms all the necessary checks
    ///      with the Lossless controller
    /// @param spender sender address
    /// @param amount amount to transfer
    /// @return bool true if the transfer was approved successfully
    function approve(
        address spender,
        uint256 amount
    ) public virtual override(ERC20) lssAprove(spender, amount) returns (bool) {
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

    /// @notice This function corresponds to the regular decrease allowance
    /// @dev This will call the lssDecreaseAllowance modifier which perofrms all the necessary checks
    ///      with the Lossless controller
    /// @param spender sender address
    /// @param subtractedValue amount to decrease allowance
    /// @return bool true if the allwance decrease was successful
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

    function withdrawTo(
        address account,
        uint256 amount
    ) public override returns (bool) {
        _burn(_msgSender(), amount);
        if (_unwrap(account, amount)) {
            return true;
        }

        return false;
    }
}
