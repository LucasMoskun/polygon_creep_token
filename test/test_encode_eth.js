
const config = require("../config/config.json")
describe("Test Encode Eth", function() {
  this.timeout(800000)

  it("Testing encode eth", async function() {

    const owner = await ethers.getSigner(0);
    console.log("Getting ABI...");
    const abi = await ethers.getContractFactory("AuthorizeCreepCoin");
    console.log("Connecting to contract");

    const contractAddress = "0xb205E9533605A8c3d2bAfA40037B05D3Ed87DF7d";
    const contract = await abi.attach(contractAddress);
    await contract.connect(owner.address);

    console.log("Authorizing... ");

    const authTx = await contract.AuthorizeCreepCoinBridge(3,4, owner.address);

    console.log("Finished");

  })
})
