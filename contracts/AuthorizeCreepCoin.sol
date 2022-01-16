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

    uint BASE_URI_LENGTH = 54;

    string BASE_URI = "ipfs://QmWbNqmucZvBNGpyP724eCsoMFqdepnnjb6o7u5oLkDdcp/";


    constructor(address _checkpointManager, address _fxRoot) FxBaseRootTunnel(_checkpointManager, _fxRoot) {

        CKNFT_ADDRESS = 0x2E0Ed7fE4CFb7D980a34CE197B9908606f2A2Af3;
    }

    function AuthorizeCreepCoinBridge(uint tokenId)
    public
    {
        address authAddress = msg.sender;
        //get suffix and tokenId
        require(queryOwner(tokenId) == authAddress, "Sender isn't token owner!");
        string memory tokenURI = queryURI(tokenId);
        uint suffixId = strToUint(substring(tokenURI, BASE_URI_LENGTH, utfStringLength(tokenURI)));
        sendMessageToChild(encodeTokenIdAndWalletAddress(tokenId, suffixId, authAddress));
        //TODO should we store here that address and token have mapped?
    }

    function queryURI(uint tokenId)
        internal
        view
        returns(string memory){
        ERC721URIStorage ckNFT = ERC721URIStorage(CKNFT_ADDRESS);
        return ckNFT.tokenURI(tokenId);
    }

    function queryOwner(uint tokenId) internal view returns (address) {
        ERC721 ckNFT = ERC721(CKNFT_ADDRESS);
        return ckNFT.ownerOf(tokenId);
    }

    function _processMessageFromChild(bytes memory data) internal override {
        latestData = data;
    }

    function sendMessageToChild(bytes memory message) internal {
        _sendMessageToChild(message);
    }

    function encodeTokenIdAndWalletAddress(uint tokenId, uint suffixId, address walletAddress)
        internal
        pure
        returns(bytes memory data) {
        return abi.encode(tokenId, suffixId, walletAddress);
    }

    function strToUint(string memory _str) internal pure returns(uint256 res) {

        for (uint256 i = 0; i < bytes(_str).length; i++) {

            res += (uint8(bytes(_str)[i]) - 48) * 10**(bytes(_str).length - i - 1);
        }

        return res;
    }

    function utfStringLength(string memory str) pure internal returns (uint length)
    {
        uint i=0;
        bytes memory string_rep = bytes(str);

        while (i<string_rep.length)
        {
            if (string_rep[i]>>7==0)
                i+=1;
            else if (string_rep[i]>>5==bytes1(uint8(0x6)))
                i+=2;
            else if (string_rep[i]>>4==bytes1(uint8(0xE)))
                i+=3;
            else if (string_rep[i]>>3==bytes1(uint8(0x1E)))
                i+=4;
            else
                //For safety
                i+=1;

            length++;
        }
    }

    function substring(string memory str, uint startIndex, uint endIndex) internal pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex-startIndex);
        for(uint i = startIndex; i < endIndex; i++) {
            result[i-startIndex] = strBytes[i];
        }
        return string (result);
    }
}
