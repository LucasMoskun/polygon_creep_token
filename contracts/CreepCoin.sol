pragma solidity ^0.8.0;

import {FxBaseChildTunnel} from "./tunnel/FxBaseChildTunnel.sol";

/**
 * @title FxStateChildTunnel
 */
contract CreepCoin is FxBaseChildTunnel {
    uint256 public latestStateId;
    address public latestRootMessageSender;
    bytes public latestData;

    uint public tokenId;
    uint public suffixId;
    address public walletAddress;

    constructor(address _fxChild) FxBaseChildTunnel(_fxChild) {}

    function _processMessageFromRoot(
        uint256 stateId,
        address sender,
        bytes memory data
    ) internal override validateSender(sender) {
        latestStateId = stateId;
        latestRootMessageSender = sender;
        latestData = data;
        (tokenId, suffixId, walletAddress) = decodeTokenIdAndWalletAddress(data);

    }

    function sendMessageToRoot(bytes memory message) public {
        _sendMessageToRoot(message);
    }

    function testReturnTokenId() public view returns(uint){
        return tokenId;
    }

    function testReturn() public pure returns(uint) {
        return 5;
    }

    function greet() public view returns (string memory) {
        return "hello world";
    }

    function decodeTokenIdAndWalletAddress(bytes memory data)
    internal
    pure
    returns(uint tokenId, uint suffixId, address walletAddress) {
        return abi.decode(data, (uint, uint, address));
    }
}
