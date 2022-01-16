
const config = require("../config/config.json")
describe("Test Encode Eth", function() {
  this.timeout(800000)

  it("Testing encode eth", async function() {

    const owner = await ethers.getSigner(0);
    console.log("Getting ABI...");
    const abi = await ethers.getContractFactory("AuthorizeCreepCoin");
    console.log("Connecting to contract");

    const contractAddress = "0x19583404319c34663C3323467206eFF25FEb3C55";
    const contract = await abi.attach(contractAddress);
    await contract.connect(owner.address);

    //Const childAddress = "0x8693ff62a594802498b04bd7da2a9f190e71ae46";
    //Const setChild = await contract.setFxChildTunnel(childAddress);
    //Console.log("setChild: ", setChild);

    console.log("Authorizing... ");
    const authTx = await contract.AuthorizeCreepCoinBridge(2);

    console.log("Finished");

  })
})
