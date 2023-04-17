// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import "forge-std/Script.sol";
import "../src/Mocks/ERC20Mock.sol";

contract DeployWrappedERC20 is Script {
    function run() external returns (TestToken) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        return new TestToken("Testing Token", "TEST", type(uint256).max);
    }
}
