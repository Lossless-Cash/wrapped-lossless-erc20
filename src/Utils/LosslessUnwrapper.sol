// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Wrapper.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";

import "forge-std/console.sol";

contract LosslessUnwrapper is Context {
    using SafeERC20 for IERC20;

    uint256 public unwrappingDelay;
    ERC20Wrapper public wrappedToken;

    struct Unwrapping {
        uint256 unwrappingAmount;
        uint256 unwrappingTimestamp;
    }

    mapping(address => Unwrapping) public unwrappingRequests;

    event UnwrapRequested(address indexed account, uint256 amount);
    event UnwrapCompleted(
        address indexed from,
        address indexed to,
        uint256 amount
    );

    constructor(uint256 _unwrappingDelay, address _underlying) {
        unwrappingDelay = _unwrappingDelay;
        wrappedToken = ERC20Wrapper(_underlying);
    }

    function requestWithdraw(uint256 amount) public {
        require(
            amount <= wrappedToken.balanceOf(_msgSender()),
            "LSS: Request exceeds balance"
        );

        Unwrapping storage unwrapping = unwrappingRequests[_msgSender()];
        unwrapping.unwrappingAmount = amount;
        unwrapping.unwrappingTimestamp = block.timestamp + unwrappingDelay;

        emit UnwrapRequested(_msgSender(), amount);
    }

    function _unwrap(
        address to,
        uint256 amount
    ) internal virtual returns (bool) {
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
        SafeERC20.safeTransfer(wrappedToken.underlying(), to, amount);

        emit UnwrapCompleted(_msgSender(), to, amount);

        return true;
    }
}
