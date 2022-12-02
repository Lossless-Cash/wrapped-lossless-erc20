// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin/contracts/access/Ownable.sol";
import "openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./LosslessWrappedERC20.sol";

contract WrappedLosslessFactory is Ownable {
    uint256 deployedWrappedERC20;
    address admin;

    constructor() {
        admin = msg.sender;
        deployedWrappedERC20 = 0;
    }

    struct TokensConfig {
        IERC20 tokenAddress;
        bool allowWrap;
        bool coreExtensionActive;
    }

    mapping(IERC20 => TokensConfig) tokenConfigs;
    mapping(uint256 => LosslessWrappedERC20) deployedWrappedContracts;

    event RegisterToken(
        IERC20 indexed _adr,
        LosslessWrappedERC20 indexed _newContract,
        bool coreExtension
    );

    modifier onlyLssAdmin() {
        require(msg.sender == admin, "wLSS-Core: Must be LSS admin");
        _;
    }

    function registerToken(IERC20 _token, bool _allowCoreExtension)
        public
        onlyLssAdmin
        returns (LosslessWrappedERC20)
    {
        TokensConfig storage tokenConfig = tokenConfigs[_token];
        tokenConfig.allowWrap = true;
        tokenConfig.coreExtensionActive = _allowCoreExtension;

        string memory name = string(
            abi.encodePacked("Lossless Wrapped ", ERC20(address(_token)).name())
        );
        string memory symbol = string(
            abi.encodePacked("wLss", ERC20(address(_token)).symbol())
        );

        LosslessWrappedERC20 newWrappedToken = new LosslessWrappedERC20(
            _token,
            name,
            symbol
        );

        deployedWrappedERC20++;

        deployedWrappedContracts[deployedWrappedERC20] = newWrappedToken;

        emit RegisterToken(_token, newWrappedToken, _allowCoreExtension);
        return newWrappedToken;
    }
}
