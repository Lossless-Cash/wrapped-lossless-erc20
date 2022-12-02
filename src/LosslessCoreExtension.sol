// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin/contracts/access/Ownable.sol";
import "openzeppelin/contracts/token/ERC20/IERC20.sol";

contract WrappedLosslessFactory is Ownable {
    address admin;

    constructor() {
        admin = msg.sender;
    }

    struct TokensConfig {
        IERC20 tokenAddress;
        bool allowWrap;
        bool coreExtensionActive;
    }

    mapping(IERC20 => TokensConfig) tokenConfigs;

    event RegisterToken(IERC20 indexed _adr, bool coreExtension);

    modifier onlyLssAdmin() {
        require(msg.sender == admin, "wLSS-Core: Must be LSS admin");
        _;
    }

    function registerToken(IERC20 _token, bool _allowCoreExtension)
        public
        onlyLssAdmin
    {
        TokensConfig storage tokenConfig = tokenConfigs[_token];
        tokenConfig.allowWrap = true;
        tokenConfig.coreExtensionActive = _allowCoreExtension;

        emit RegisterToken(_token, _allowCoreExtension);
    }
}
