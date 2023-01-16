// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./LosslessWrappedERC20Extensible.sol";
import "./LosslessWrappedERC20.sol";
import "./LosslessWrappedERC20Adminless.sol";

contract WrappedLosslessFactory {
    function registerWrappedToken(
        IERC20 _token,
        address admin_,
        address recoveryAdmin_,
        uint256 timelockPeriod_,
        address lossless_,
        bool hasAdmin,
        bool isExtensible
    ) public returns (address) {
        string memory name = ERC20(address(_token)).name();

        string memory symbol = string(
            abi.encodePacked("wL", ERC20(address(_token)).symbol())
        );

        if (isExtensible) {
            symbol = string(abi.encodePacked(symbol, "e"));
            LosslessWrappedERC20Extensible newWrappedToken = new LosslessWrappedERC20Extensible(
                    _token,
                    name,
                    symbol,
                    msg.sender
                );

            return address(newWrappedToken);
        } else {
            if (hasAdmin) {
                LosslessWrappedERC20 newWrappedToken = new LosslessWrappedERC20(
                    _token,
                    name,
                    symbol,
                    admin_,
                    recoveryAdmin_,
                    timelockPeriod_,
                    lossless_
                );

                return address(newWrappedToken);
            } else {
                LosslessWrappedERC20Adminless newWrappedToken = new LosslessWrappedERC20Adminless(
                        _token,
                        name,
                        symbol,
                        lossless_
                    );
                return address(newWrappedToken);
            }
        }
    }
}
