// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/LosslessWrappedERC20.sol";

contract DeployAdminless is Script {
    function run() external returns (LosslessWrappedERC20) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address underlyingToken = 0xA6492ceD95e07A6Bef76F182377c896F3cf3e29b;
        address losslessController = 0xe91D7cEBcE484070fc70777cB04F7e2EfAe31DB4;

        vm.broadcast(deployerPrivateKey);

        return
            new LosslessWrappedERC20(
                IERC20(underlyingToken),
                "Test Adminless",
                "wLTSTe",
                losslessController,
                3 hours,
                15 minutes
            );
    }
}
