// SPDX-License-Identifier: MIT
pragma solidity 0.7.3;

import { ERC20 } from "../lib/ERC20.sol";
import { IFxERC20 } from "./IFxERC20.sol";


/** 
 * @title FxERC20 represents fx erc20
 */
contract FxERC20 is IFxERC20, ERC20 {
    address private _fxManager;
    address private _rootToken;

    function initialize(address fxManager_, address rootToken_, string memory name_, string memory symbol_, uint8 decimals_) public override {
        require(fxManager_ == address(0x0) && rootToken_ == address(0x0), "Token is already initialized");
        _fxManager = fxManager_;
        _rootToken = rootToken_;

        // setup meta data
        setupMetaData(name_, symbol_, decimals_);
    }

    // fxManager rturns fx manager
    function fxManager() public override view returns (address) {
      return _fxManager;
    }

    // rootToken returns root token
    function rootToken() public override view returns (address) {
      return _rootToken;
    }

    // setup name, symbol and decimals
    function setupMetaData(string memory _name, string memory _symbol, uint8 _decimals) public {
        require(msg.sender == _fxManager, "Invalid sender");
        _setupMetaData(_name, _symbol, _decimals);
    }

    function deposit(address user, uint256 amount) public override {
        require(msg.sender == _fxManager, "Invalid sender");
        _mint(user, amount);
    }

    function withdraw(address user, uint256 amount) public override {
        require(msg.sender == _fxManager, "Invalid sender");
        _burn(user, amount);
    }
}