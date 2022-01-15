require("dotenv").config();
const config = require("../config/config.json")
const hre = require("hardhat");

async function main() {

  const network = await hre.ethers.provider.getNetwork();

  console.log("chain ID: ", network.chainId)

  let fxChild

  if(network.chainId === 137) {
    console.log("Polygon main");
    fxChild = config.mainnet.fxChild.address;
  }
  else if (network.chainId === 80001) {
    console.log("Mumbai testnet");
    fxChild = config.testnet.fxChild.address;
  }
  else {
    console.log("Error, no requested network detected!");
    return;
  }


  const owner = await ethers.getSigner(0);
  console.log("Getting ABI");
  const abi = await ethers.getContractFactory("FxStateChildTunnel");
  console.log("Deploying contract");
  const contract = await abi.deploy(fxChild);

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
