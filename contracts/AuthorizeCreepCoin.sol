// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {FxBaseRootTunnel} from "./tunnel/FxBaseRootTunnel.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

/**
 * @title FxStateRootTunnel
 */
contract AuthorizeCreepCoin is FxBaseRootTunnel {
    bytes public latestData;

    address public CKNFT_ADDRESS;

    string private testURI;


    constructor(address _checkpointManager, address _fxRoot) FxBaseRootTunnel(_checkpointManager, _fxRoot) {

        CKNFT_ADDRESS = 0x2E0Ed7fE4CFb7D980a34CE197B9908606f2A2Af3;
    }


    function getStoredURI() public view returns (string memory) {
        return testURI;
    }

    function queryURI(string memory _greeting) public {
        ERC721URIStorage ckNFT = ERC721URIStorage(CKNFT_ADDRESS);
        testURI = ckNFT.tokenURI(1);
    }

    function _processMessageFromChild(bytes memory data) internal override {
        latestData = data;
    }

    function sendMessageToChild(bytes memory message) internal {
        _sendMessageToChild(message);
    }

    function AuthorizeCreepCoinBridge(uint tokenId, uint suffixId, address walletAddress)
    public
    {
        sendMessageToChild(encodeTokenIdAndWalletAddress(tokenId, suffixId, walletAddress));
    }

    function encodeTokenIdAndWalletAddress(uint tokenId, uint suffixId, address walletAddress)
        internal
        pure
        returns(bytes memory data) {
        return abi.encode(tokenId, suffixId, walletAddress);
    }
}
