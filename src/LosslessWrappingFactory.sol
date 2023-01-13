// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "openzeppelin/contracts/token/ERC20/IERC20.sol";
import "openzeppelin/contracts/access/Ownable.sol";
import "openzeppelin/contracts/access/AccessControl.sol";
import "./LosslessWrappedERC20Extensible.sol";
import "./LosslessWrappedERC20.sol";
import "./LosslessWrappedERC20Adminless.sol";

contract WrappedLosslessFactory {
    event RegisterExtensibleToken(IERC20, LosslessWrappedERC20Extensible);
    event RegisterProtectedToken(IERC20, LosslessWrappedERC20Protected);
    event RegisterAdminlessProtectedToken(
        IERC20,
        LosslessWrappedERC20ProtectedAdminless
    );

    function registerExtensibleToken(IERC20 _token)
        public
        returns (LosslessWrappedERC20Extensible)
    {
        require(
            callDetectOwnable(address(_token)) ||
                callDetectAccessControl(address(_token)),
            "LSS: Needs to implement admin or ownership"
        );
        string memory name = string(
            abi.encodePacked(
                "Lossless Extensible Wrapped ",
                ERC20(address(_token)).name()
            )
        );
        string memory symbol = string(
            abi.encodePacked("wL", ERC20(address(_token)).symbol(), "e")
        );

        LosslessWrappedERC20Extensible newWrappedToken = new LosslessWrappedERC20Extensible(
                _token,
                name,
                symbol,
                msg.sender
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
        require(
            callDetectOwnable(address(_token)) ||
                callDetectAccessControl(address(_token)),
            "LSS: Needs to implement admin or ownership"                    // Maybe this is not needed, maybe some projects don't have admin on their erc20, but want to have admin voting power on lossless protocol
        );

        string memory name = string(
            abi.encodePacked(
                "Lossless Protected Wrapped ",
                ERC20(address(_token)).name()
            )
        );
        string memory symbol = string(
            abi.encodePacked("wL", ERC20(address(_token)).symbol())
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

    function registerAdminlessProtectedToken(
        IERC20 _token,
        uint256 timelockPeriod_,                // unused variable
        address lossless_
    ) public returns (LosslessWrappedERC20ProtectedAdminless) {
        require(
            !callDetectOwnable(address(_token)) &&
                !callDetectAccessControl(address(_token)),
            "LSS: only for adminless tokens"                            // Maybe we don't need this check, some projects might still want adminless tokens even if they have admins on their token
        );

        string memory name = string(
            abi.encodePacked(
                "Lossless Adminless Protected Wrapped ",
                ERC20(address(_token)).name()
            )
        );
        string memory symbol = string(
            abi.encodePacked("waL", ERC20(address(_token)).symbol())
        );

        LosslessWrappedERC20ProtectedAdminless newWrappedToken = new LosslessWrappedERC20ProtectedAdminless(
                _token,
                name,
                symbol,
                lossless_
            );

        emit RegisterAdminlessProtectedToken(_token, newWrappedToken);
        return newWrappedToken;
    }

    function callDetectOwnable(address _token) public view returns (bool) {
        // Encode the function selector and arguments for the `getRoleAdmin` function           // I think this comment is not needed
        bytes memory data = abi.encodeWithSelector(
            bytes4(keccak256("owner()"))
        );

        // Call the `getRoleAdmin` function using the STATICCALL opcode
        // pragma ignore "Unused local variable."

        (bool success, bytes memory returnValue) = address(_token).staticcall(      // I think you can use (bool success,) if you don't need the second variable
            data
        );

        return success;
    }

    function callDetectAccessControl(address _token)
        public
        view
        returns (bool)
    {
        // Encode the function selector and arguments for the `getRoleAdmin` function       // I think this comment is not needed
        bytes memory data = abi.encodeWithSelector(
            bytes4(keccak256("getRoleAdmin(bytes32)")),
            "0x00"
        );

        // Call the `getRoleAdmin` function using the STATICCALL opcode
        // pragma ignore "Unused local variable."
        (bool success, bytes memory returnValue) = address(_token).staticcall(  // I think you can use (bool success,) if you don't need the second variable
            data
        );

        return success;
    }
}
