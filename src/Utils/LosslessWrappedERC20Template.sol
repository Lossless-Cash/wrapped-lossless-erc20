// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin/contracts/token/ERC20/IERC20.sol";
import "openzeppelin/contracts/token/ERC20/extensions/ERC20Wrapper.sol";

contract LosslessWrappedERC20 is ERC20Wrapper {
    uint256 public constant VERSION = 1;

    constructor(
        IERC20 _underlyingToken,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) ERC20Wrapper(_underlyingToken) {}
}
