
const config = require("../config/config.json")
describe("Test Encode Eth", function() {
  this.timeout(800000)

  it("Testing encode eth", async function() {

    const owner = await ethers.getSigner(0);
    console.log("Getting ABI...");
    const abi = await ethers.getContractFactory("AuthorizeCreepCoin");
    console.log("Connecting to contract");

    const contractAddress = "0x672C4838c6642e7125d9F0024b38F033238C0Ddd";
    const contract = await abi.attach(contractAddress);
    await contract.connect(owner.address);

    //const childAddress = "0x0ece8a8ba0a6ec83ff51ba70d2af6955b3178d5c";
    //const setChild = await contract.setFxChildTunnel(childAddress);
    //console.log("setChild: ", setChild);

    console.log("Authorizing... ");
    const authTx = await contract.AuthorizeCreepCoinBridge(3);

    console.log("Finished");

  })
})
