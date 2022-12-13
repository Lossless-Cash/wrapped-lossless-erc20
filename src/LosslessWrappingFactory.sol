// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin/contracts/access/AccessControl.sol";
import "openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./LosslessWrappedERC20Extensible.sol";

contract WrappedLosslessFactory is AccessControl {
    event RegisterToken(IERC20, LosslessWrappedERC20Extensible);

    function registerToken(IERC20 _token)
        public
        returns (LosslessWrappedERC20Extensible)
    {
        string memory name = string(
            abi.encodePacked("Lossless Wrapped ", ERC20(address(_token)).name())
        );
        string memory symbol = string(
            abi.encodePacked("wLss", ERC20(address(_token)).symbol())
        );

        LosslessWrappedERC20Extensible newWrappedToken = new LosslessWrappedERC20Extensible(
                _token,
                name,
                symbol
            );

        emit RegisterToken(_token, newWrappedToken);
        return newWrappedToken;
    }
}
