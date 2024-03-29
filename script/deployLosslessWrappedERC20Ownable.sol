// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import "forge-std/Script.sol";
import "../src/LosslessWrappedERC20Ownable.sol";

contract DeployWrappedERC20 is Script {
    function run() external returns (LosslessWrappedERC20Ownable) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address underlyingToken = 0xA6492ceD95e07A6Bef76F182377c896F3cf3e29b;
        address admin = 0x06F2075587fa961E4Bf7e9c01c5c8EFf69C52837;
        address losslessController = 0xe91D7cEBcE484070fc70777cB04F7e2EfAe31DB4;

        vm.startBroadcast(deployerPrivateKey);

        return
            new LosslessWrappedERC20Ownable(
                IERC20(underlyingToken),
                "Test Wrapped",
                "wlTST",
                admin,
                admin,
                24 hours,
                losslessController,
                3 hours
            );
    }
}
