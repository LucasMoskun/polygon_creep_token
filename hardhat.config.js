require("dotenv").config();
require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */

const {ETHERSCAN_API, MAIN_API_URL, API_URL, METAMASK_PRIVATE_KEY, COIN_API} = process.env;

let accounts = [];
accounts = [`0x${METAMASK_PRIVATE_KEY}`]

module.exports = {
  solidity: {
    version: "0.8.0",
    defaultNetwork: "hardhat",
    settings: {
      optimizer: {
        enabled: true,
        runs: 9999,
      },
    },
  },
  networks: {
    mainnet: {
      url: process.env.MAINNET_RPC || "https://main-light.eth.linkpool.io",
      accounts,
    },
    goerli: {
      url: process.env.GOERLI_RPC || "https://goerli-light.eth.linkpool.io",
      accounts,
    },
    polygon: {
      url: process.env.POLYGON_RPC || "https://polygon-rpc.com",
      accounts,
    },
    mumbai: {
      url: process.env.MUMBAI_RPC || "https://rpc-mumbai.maticvigil.com",
      accounts,
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY || "",
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  }
};
