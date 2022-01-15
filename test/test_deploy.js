
describe("Fx Portal Deploy", function() {
  this.timeout(800000)
  it("Deploying fx portal contract", async function() {
    console.log("Starting...")

    const owner = await ethers.getSigner(0);
    console.log("Getting ABI");
    const abi = await ethers.getContractFactory("FxStateRootTunnel.sol")
    console.log("Deploying contract...");
    const contract = await token.deploy();
    console.log("Contract addres: " + contract.address);
    console.log("transaction hash: " + contract.deployTransaction.hash);
    await contract.deployed();
    console.log("contract deployed")
  })
})
