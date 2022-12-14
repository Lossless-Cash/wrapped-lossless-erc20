// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./LosslessWrappedERC20Extensible.sol";
import "./LosslessWrappedERC20Protected.sol";

contract WrappedLosslessFactory {
    event RegisterExtensibleToken(IERC20, LosslessWrappedERC20Extensible);
    event RegisterProtectedToken(IERC20, LosslessWrappedERC20Protected);

    function registerExtensibleToken(IERC20 _token)
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

        emit RegisterExtensibleToken(_token, newWrappedToken);
        return newWrappedToken;
    }

    function registerProtectedToken(
        IERC20 _token,
        address admin_,
        address recoveryAdmin_,
        uint256 timelockPeriod_,
        address lossless_
    ) public returns (LosslessWrappedERC20Protected) {
        string memory name = string(
            abi.encodePacked("Lossless Wrapped ", ERC20(address(_token)).name())
        );
        string memory symbol = string(
            abi.encodePacked("wLss", ERC20(address(_token)).symbol())
        );

        LosslessWrappedERC20Protected newWrappedToken = new LosslessWrappedERC20Protected(
                _token,
                name,
                symbol,
                admin_,
                recoveryAdmin_,
                timelockPeriod_,
                lossless_
            );

        emit RegisterProtectedToken(_token, newWrappedToken);
        return newWrappedToken;
    }
}
