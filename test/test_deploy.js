const { ethers } = require("hardhat");
describe("Fx Portal Deploy", function() {
  this.timeout(800000)

  it("Deploying fx portal contract", async function() {
    console.log("Starting...")

    const owner = await ethers.getSigner(0);
    console.log("Getting ABI");
    const abi = await ethers.getContractFactory("FxStateRootTunnel")
    console.log("Deploying contract...");
    const contract = await abi.deploy();
    console.log("Contract addres: " + contract.address);
    console.log("transaction hash: " + contract.deployTransaction.hash);
    await contract.deployed();
    console.log("contract deployed")
  })
})
