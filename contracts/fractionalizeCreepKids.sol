// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract fractionalizeCreepKids {
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

    string metadataUri;
    address CreepKidsNFTSmartContractAddress;
    mapping(address=>CoinHolder) addressToCoinHolder;
    mapping(uint=>address) TokenIDToAuthorizedMinterAddress;
    mapping(uint=>bool) TokenIDtoAreFractionalizedCoinsMinted;

    constructor () {
        CreepKidsNFTSmartContractAddress = 0x7ef232E01C45377b0321ff11cA50c59C5B69212b;
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
    ) private {
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
    ) private {
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

    function _removeTokenIDfromCoinHolder(
        CoinHolder storage coinHolderToCheck,
        uint TokenID
    ) private {
        uint removalIndex;
        bool found;
        uint i;
        for (i=0; i < coinHolderToCheck.TokenIDsHeld.length; i++) {
            if (TokenID == coinHolderToCheck.TokenIDsHeld[i]) {
                removalIndex = i;
                found = true;
                break;
            }
        }
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

        //Increment receiverCoinHolder => TokenID => Count by AmountCoinToSend

        //Assert receiverCoinHolder holds the TokenID and has original quantity + sent quantity, if not revert

        //Assert senderCoinHolder holds the TokenID and has original quantity - sent quantity,
        //  OR does not hold TokenID if quant = 0 if not revert

    }

    function balance(
        address addressToCheckBalance,
        uint TokenID
    ) public view returns(uint) {
        return addressToCoinHolder[addressToCheckBalance].TokenIDtoCoinCount[TokenID];
    }
}