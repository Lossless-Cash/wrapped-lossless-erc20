// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/Mocks/ERC20OwnableMock.sol";

contract DeployMockERC20 is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        OwnableTestToken erc20Ownable = new OwnableTestToken(
            "Test Token",
            "TST",
            100000000000000000
        );

        vm.stopBroadcast();
    }
}
