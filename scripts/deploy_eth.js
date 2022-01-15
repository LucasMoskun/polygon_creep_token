
require("dotenv").config();
const config = require("../config/config.json")
const hre = require("hardhat");

async function main() {

  const network = await hre.ethers.provider.getNetwork();

  console.log("chain ID: ", network.chainId)

  let fxRoot, checkpointManager;

  if(network.chainId === 1) {
    console.log("Eth main");
    checkpointManager = config.mainnet.checkpointManager.address;
    fxRoot = config.mainnet.fxRoot.address;
  }
  else if (network.chainId === 5) {
    console.log("Goerli testnet");
    checkpointManager = config.testnet.checkpointManager.address;
    fxRoot = config.testnet.fxRoot.address;
  }
  else {
    console.log("Error, no requested network detected!");
    return;
  }


  const owner = await ethers.getSigner(0);
  console.log("Getting ABI");
  const abi = await ethers.getContractFactory("FxStateRootTunnel");
  console.log("Deploying contract");
  const contract = await abi.deploy(checkpointManager, fxRoot);

  console.log("Contract addres: " + contract.address);
  console.log("transaction hash: " + contract.deployTransaction.hash);
  await contract.deployed();
  console.log("contract deployed")

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
