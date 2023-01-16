// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "openzeppelin/contracts/utils/introspection/IERC165.sol";

interface ICoreExtension is IERC165 {
    event ExtensionRegistered(
        address indexed extension,
        address indexed sender
    );
    event ExtensionUnregistered(
        address indexed extension,
        address indexed sender
    );

    event BeforeTransferUpdated(address extension);
    event AfterTransferUpdated(address extension);
    event BeforeTransferFromUpdated(address extension);
    event AfterTransferFromUpdated(address extension);
    event BeforeMintUpdated(address extension);
    event AfterMintUpdated(address extension);
    event BeforeBurnUpdated(address extension);
    event AfterBurnUpdated(address extension);
    event BeforeBurnFromUpdated(address extension);
    event AfterBurnFromUpdated(address extension);

    function getExtensions() external view returns (address[] memory);

    function registerExtension(address extension) external;

    function unregisterExtension(address extension) external;

    function setBeforeTransferExtension() external;

    function setAfterTransferExtension() external;

    function setBeforeTransferFromExtension() external;

    function setAfterTransferFromExtension() external;

    function setBeforeMintExtension() external;

    function setAfterMintExtension() external;

    function setBeforeBurnExtension() external;

    function setAfterBurnExtension() external;

    function setBeforeBurnFromExtension() external;

    function setAfterBurnFromExtension() external;
}
