// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract fractionalizeCreepKids{
    struct CoinHolder {
        // 1 struct per address, contains mapping of tokenIDs to coin count,
        // and list of TokenIDs held
        //
        // ex: address 0x1 holds tokens 23 (70 coins) and 34 (100 coins)
        // address = 0x1
        // TokenIDtoCoinCount = {23:70, 34:100}
        // TokenIDsHeld = [23,34] // we need this to be able to iterate over TokenIDs
        // address addressOfHolder; //CHECK PLEASE: this may be redundant due to below "addressToCoinHolder" mapping
        mapping(uint=>uint) TokenIDtoCoinCount;
        uint[] TokenIDsHeld;
        bool initialized;
        // We could also eliminate TokenIDsHeld and loop through all 1000, test for performance
    }

    string constant metadataUri = "ipfs://QmcrVNTcC9DTGia2YbdrYchzt26te94DkEGikPNd3q1Ug3";
    address CreepKidsNFTSmartContractAddress;
    mapping(address=>CoinHolder) public addressToCoinHolder;
    mapping(uint=>address) public TokenIDToAuthorizedMinterAddress;
    mapping(uint=>uint) public TokenIDToURISuffix;
    mapping(uint=>bool) public TokenIDtoAreFractionalizedCoinsMinted;

    constructor () {
        CreepKidsNFTSmartContractAddress = 0x7ef232E01C45377b0321ff11cA50c59C5B69212b;
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

    function getURI(uint TokenID) public pure returns (string memory) {
        return string(abi.encodePacked(metadataUri, "/", _uintToString(TokenID)));
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
        uint TokenID
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

        //Map given TokenID to given Address
        TokenIDToAuthorizedMinterAddress[TokenID] = addressOfHolder;
    }

    function _lookupOrCreateCoinHolder(
        address addressOfCoinHolder
    ) private returns (CoinHolder storage) {
        if (addressToCoinHolder[addressOfCoinHolder].initialized) {
            return addressToCoinHolder[addressOfCoinHolder];
        } else {
            CoinHolder storage returnCoinHolder = addressToCoinHolder[addressOfCoinHolder];
            returnCoinHolder.initialized = true;
            return returnCoinHolder;
        }
    }

    function mintCreepCoins(
        address addressOfHolder,
        uint TokenID
    ) public {
        _checkValidTokenIDAndOwnershipAndNotYetMinted(TokenID);

        //  Check for minting authorization in TokenIDToAuthorizedMinterAddress
        require(TokenIDToAuthorizedMinterAddress[TokenID] == addressOfHolder,
            "ERROR: Address is not yet authorized to mint this TokenID.");

        //  _lookupOrCreateCoinHolder to get CoinHolder object
        CoinHolder storage mintersCoinHolder = _lookupOrCreateCoinHolder(addressOfHolder);

        //  Mint the CreepCoins
        //      Do this in the CoinHolder object
        //          1. Add TokenID to the TokenIDsHeld
        mintersCoinHolder.TokenIDsHeld.push(TokenID);
        //          2. Add mapping of TokenID => 100 in TokenIDtoCoinCount       
        mintersCoinHolder.TokenIDtoCoinCount[TokenID] = 100;

        //  Mark the TokenID as minted in TokenIDtoAreFractionalizedCoinsMinted
        TokenIDtoAreFractionalizedCoinsMinted[TokenID] = true;
    }

    function _checkCoinHolderHasExactlyCountOfTokenIDCoins(
        CoinHolder storage coinHolderToCheck,
        uint expectedCountOfCoin,
        uint TokenID
    ) private view {
        require(coinHolderToCheck.TokenIDtoCoinCount[TokenID] == expectedCountOfCoin,
            "ERROR: Expected Coin Count does not match actual Coin Count.");
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

    function _removeTokenIDfromCoinHolder(
        CoinHolder storage coinHolderToCheck,
        uint TokenID
    ) private {
        uint removalIndex;
        bool found;
        
        (removalIndex, found) = _findIndexOfValueInArray(TokenID, coinHolderToCheck.TokenIDsHeld);

        require(!found,
            "ERROR: TokenID not found in CoinHolder.TokenIDsHeld");

        coinHolderToCheck.TokenIDsHeld[removalIndex] = coinHolderToCheck.TokenIDsHeld[coinHolderToCheck.TokenIDsHeld.length - 1];
        coinHolderToCheck.TokenIDsHeld.pop();
    }

    function transferCreepCoinsToAddress(
        address addressOfSender,
        address addressOfReceiver,
        uint TokenID,
        uint AmountCoinToSend
    ) public {
        require(addressOfSender != addressOfReceiver,
            "ERROR: Sender and receiver must be different addresses.");

        _checkValidTokenID(TokenID);

        //_lookupOrCreateCoinHolder to get senderCoinHolder object
        CoinHolder storage senderCoinHolder = _lookupOrCreateCoinHolder(addressOfSender);

        //_lookupOrCreateCoinHolder to get receiverCoinHolder object
        CoinHolder storage receiverCoinHolder = _lookupOrCreateCoinHolder(addressOfReceiver);

        //Check AmountCoinToSend >0 and <= 100
        require(AmountCoinToSend > 0 && AmountCoinToSend <= 100,
            "ERROR: Transfer amount must be 1-100.");

        //Check senderCoinHolder holds the TokenID and has sufficient quantity
        require(senderCoinHolder.TokenIDtoCoinCount[TokenID] >= AmountCoinToSend,
            "ERROR: Sender did not have enough CreepCoin for this transfer.");

        //Save original quantity of receiverCoinHolder => TokenID => Count
        uint receiverOriginalCoinCount = receiverCoinHolder.TokenIDtoCoinCount[TokenID];

        //Save original quantity of senderCoinHolder => TokenID => Count
        uint senderOriginalCoinCount = senderCoinHolder.TokenIDtoCoinCount[TokenID];

        //Decrement senderCoinHolder => TokenID => Count by AmountCoinToSend
        senderCoinHolder.TokenIDtoCoinCount[TokenID] -= AmountCoinToSend;

        //If sender runs out of that TokenID coins, remove TokenID from TokenIDs list in senderCoinHolder
        if (AmountCoinToSend == senderOriginalCoinCount) {
            _removeTokenIDfromCoinHolder(senderCoinHolder, TokenID);
        }

        //Add TokenID to TokenIDs list in receiverCoinHolder IF NOT ALREADY THERE (see original quantity of receiver)
        (, bool found) = _findIndexOfValueInArray(TokenID, receiverCoinHolder.TokenIDsHeld);
        if (!found) {
            receiverCoinHolder.TokenIDsHeld.push(TokenID);
        }

        //Increment receiverCoinHolder => TokenID => Count by AmountCoinToSend
        receiverCoinHolder.TokenIDtoCoinCount[TokenID] += AmountCoinToSend;

        //Assert receiverCoinHolder holds the TokenID and has original quantity + sent quantity, if not revert
        require(receiverCoinHolder.TokenIDtoCoinCount[TokenID] == receiverOriginalCoinCount + AmountCoinToSend, 
            "ERROR: receiver's new balance different than expected.");

        //Assert senderCoinHolder has original quantity - sent quantity
        require(senderCoinHolder.TokenIDtoCoinCount[TokenID] == senderOriginalCoinCount - AmountCoinToSend, 
            "ERROR: sender's new balance different than expected.");

        //Assert senderCoinHolder has TokenID if non-zero CreepCoin remaining
        if (senderOriginalCoinCount - AmountCoinToSend == 0) {
            (, found) = _findIndexOfValueInArray(TokenID, senderCoinHolder.TokenIDsHeld);
            require(!found,
                "ERROR: TokenID was not removed from sender's CoinHolder.TokenIDsHeld.");
        }

        //Assert receiverCoinHolder has TokenID
        (, found) = _findIndexOfValueInArray(TokenID, receiverCoinHolder.TokenIDsHeld);
        require(found,
            "ERROR: TokenID was not added to receiver's CoinHolder.TokenIDsHeld.");
    }

    function balance(
        address addressToCheckBalance,
        uint TokenID
    ) public view returns(uint) {
        require(addressToCoinHolder[addressToCheckBalance].initialized,
            "ERROR: Given Address has not initialized its CoinHolder");
        return addressToCoinHolder[addressToCheckBalance].TokenIDtoCoinCount[TokenID];
    }

    function totalBalance(
        address addressToCheckBalance
    ) public view returns(uint) {
        uint[] storage TokenIDs = addressToCoinHolder[addressToCheckBalance].TokenIDsHeld;
        uint i;
        uint returnSum;
        for (i=0; i<TokenIDs.length; i++) {
            returnSum += addressToCoinHolder[addressToCheckBalance].TokenIDtoCoinCount[TokenIDs[i]];
        }
        return returnSum;
    }
}

/**
TODO:
- Install Node/npm
- Install Truffle
- Install Hardhat
- Find working Goerli and Mumbai faucets
- Deploy smart contracts to Goerli and Mumbai
 */