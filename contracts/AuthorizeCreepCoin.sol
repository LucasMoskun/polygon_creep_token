// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {FxBaseRootTunnel} from "./tunnel/FxBaseRootTunnel.sol";

/**
 * @title FxStateRootTunnel
 */
contract AuthorizeCreepCoin is FxBaseRootTunnel {
    bytes public latestData;

    constructor(address _checkpointManager, address _fxRoot) FxBaseRootTunnel(_checkpointManager, _fxRoot) {}

    function _processMessageFromChild(bytes memory data) internal override {
        latestData = data;
    }

    function sendMessageToChild(bytes memory message) internal {
        _sendMessageToChild(message);
    }

    function AuthorizeCreepCoinBridge(uint tokenId, uint suffixId, address walletAddress)
    public
    {
        sendMessageToChild(encodeTokerIdAndWalletAddress(tokenId, suffixId, walletAddress));
    }

    function encodeTokenIdAndWalletAddress(uint tokenId, uint suffixId, address walletAddress)
        internal
        pure
        returns(bytes memory data) {
        return abi.encode(tokenId, suffixId, walletAddress);
    }
}
