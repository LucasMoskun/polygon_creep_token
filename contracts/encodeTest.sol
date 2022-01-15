// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title EncodeTest
 * @dev Test encode and decoding
 */
contract EncodeTest {

    function encodeTokenIdAndWalletAddress(uint tokenId, uint suffixId, address walletAddress) public pure returns(bytes memory data) {
        return abi.encode(tokenId, suffixId, walletAddress);
    }

    function decodeTokenIdAndWalletAddress(bytes memory data) public pure returns(uint tokenId, uint suffixId, address walletAddress) {
        return abi.decode(data, (uint, uint, address));
    }

}