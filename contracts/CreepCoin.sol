// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {FxBaseChildTunnel} from "./tunnel/FxBaseChildTunnel.sol";

contract CreepCoin is ERC1155, FxBaseChildTunnel {
    string constant METADATA_URI = "ipfs://QmcrVNTcC9DTGia2YbdrYchzt26te94DkEGikPNd3q1Ug3";
    uint constant QUANTITY_TO_MINT = 100;
    string public constant name = "Creep Coin";
    string public constant symbol = "CCT";

    mapping(uint=>address) public TokenIDToAuthorizedMinterAddress;
    mapping(uint=>uint) public TokenIDToURISuffix;
    mapping(uint=>bool) public TokenIDtoAreFractionalizedCoinsMinted;

    uint256 public latestStateId;
    address public latestRootMessageSender;
    bytes public latestData;

    constructor(address _fxChild) FxBaseChildTunnel(_fxChild) ERC1155("creepkids.io"){
    }

    function sendMessageToRoot(bytes memory message) public {
        _sendMessageToRoot(message);
    }

    function decodeTokenIdAndWalletAddress(bytes memory data)
    internal
    pure
    returns(uint, uint, address) {
        return abi.decode(data, (uint, uint, address));
    }

    function _processMessageFromRoot(
        uint256 stateId,
        address sender,
        bytes memory data
    ) internal override validateSender(sender) { 
        // This function receives authorization requests from Ethereum blockchain via FxPortal and executes them
        latestStateId = stateId;
        latestRootMessageSender = sender;
        latestData = data;
        (uint tokenId, uint suffixId, address walletAddress) = decodeTokenIdAndWalletAddress(data);
        authorizeAddressToMintTokenID(walletAddress, tokenId, suffixId);
    }

    function mint(uint TokenID, address addressOfRecipient, string memory TokenURI) public {
        _mint(addressOfRecipient, TokenID, QUANTITY_TO_MINT, bytes(TokenURI)); 
        // Wait a second, aren't we minting to the same address on polygon side? Can we do that?
        // Does my MetaMask wallet address work on polygon chain?
    }

    function _uintToString(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function getURI(uint TokenID) public view returns (string memory) {
        require(TokenIDToURISuffix[TokenID] != 0,
            "ERROR: URI Suffix not found for given TokenID");
        return string(abi.encodePacked(METADATA_URI, "/", _uintToString(TokenIDToURISuffix[TokenID])));
    }

    function _checkValidTokenID (
        uint TokenID
    ) private pure returns (bool) {
        return TokenID >= 0 && TokenID <= 1000;
    }

    function _checkValidTokenIDAndOwnershipAndNotYetMinted (
        uint TokenID
    ) private view {
        require(_checkValidTokenID(TokenID),
            "ERROR: TokenID invalid.");

        //  Check if the TokenID's CreepCoins have already been minted
        //  use TokenIDtoAreFractionalizedCoinsMinted
        require(!TokenIDtoAreFractionalizedCoinsMinted[TokenID],
            "ERROR: TokenID's fractional CreepCoins have already been minted.");
    }

    function authorizeAddressToMintTokenID(
        address addressOfHolder,
        uint TokenID,
        uint URISuffixID
    ) public {
        _checkValidTokenIDAndOwnershipAndNotYetMinted(TokenID);

        //  DO NOT check if the TokenID already has an authorized minter address
        //  consider the following case:
        //      address 0x1 owns TokenID 5
        //      address 0x1 authorizes TokenID 5 for CreepCoinMinting
        //          mapping in TokenIDToAuthorizedMinterAddress: 5=>0x1
        //      address 0x1 transfers TokenID 5 to address 0x2
        //      address 0x2 authorizes TokenID 5 for CreepCoinMinting
        //          we WANT to overwrite mapping in TokenIDToAuthorizedMinterAddress: 5=>0x2
        //
        require(URISuffixID != 0,
            "ERROR: Cannot authorize mint with URI Suffix = 0");
        //Map given TokenID to given Address
        TokenIDToAuthorizedMinterAddress[TokenID] = addressOfHolder;
        TokenIDToURISuffix[TokenID] = URISuffixID;
    }

    function mintCreepCoins(
        address addressOfHolder,
        uint TokenID
    ) public {
        _checkValidTokenIDAndOwnershipAndNotYetMinted(TokenID);

        //  Check for minting authorization in TokenIDToAuthorizedMinterAddress
        require(TokenIDToAuthorizedMinterAddress[TokenID] == addressOfHolder,
            "ERROR: Address is not yet authorized to mint this TokenID.");

        mint(TokenID, addressOfHolder, getURI(TokenID));

        //  Mark the TokenID as minted in TokenIDtoAreFractionalizedCoinsMinted
        TokenIDtoAreFractionalizedCoinsMinted[TokenID] = true;
    }

    function _findIndexOfValueInArray(
        uint searchValue,
        uint[] storage searchArray
    ) private view returns (uint, bool) {
        uint foundIndex;
        bool found;
        uint i;
        for (i=0; i < searchArray.length; i++) {
            if (searchValue == searchArray[i]) {
                foundIndex = i;
                found = true;
                break;
            }
        }
        return (foundIndex, found);
    }
}
