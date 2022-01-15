const config = require("../config/config.json")
describe("Fx Portal Deploy", function() {
  this.timeout(800000)

  it("Deploying fx portal contract", async function() {
    console.log("Starting...")

    const checkpointManager = config.testnet.checkpointManager.address;
    const fxRoot = config.testnet.fxRoot.address;

    const owner = await ethers.getSigner(0);
    console.log("Getting ABI");
    const abi = await ethers.getContractFactory("FxStateRootTunnel")
    //const abi = await ethers.getContractFactory("HelloWorld")
    console.log("Deploying contract...");
    const contract = await abi.deploy(checkpointManager, fxRoot);
    console.log("Contract addres: " + contract.address);
    console.log("transaction hash: " + contract.deployTransaction.hash);
    await contract.deployed();
    console.log("contract deployed")
  })
})
