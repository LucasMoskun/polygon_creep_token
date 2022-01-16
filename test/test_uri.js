
const config = require("../config/config.json")
describe("Test Encode Eth", function() {
  this.timeout(800000)

  it("Testing encode eth", async function() {

    const owner = await ethers.getSigner(0);
    console.log("Getting ABI...");
    const abi = await ethers.getContractFactory("AuthorizeCreepCoin");
    console.log("Connecting to contract");

    const contractAddress = "0x03AfA5dA0ebf80f679Dc20810F719a6d088A0E30";
    const contract = await abi.attach(contractAddress);
    await contract.connect(owner.address);

   // const childAddress = "0xaec317cb2990edcf6752234ec0c28fe7c45fe8f1";
   // const setChild = await contract.setFxChildTunnel(childAddress);
   // console.log("setChild: ", setChild);
   // console.log("Authorizing... ");

    //const queryURI = await contract.queryURI("YOOO");

    const storedURI = await contract.getStoredURI();
    console.log("Stored URI: ", storedURI);
    //const authTx = await contract.AuthorizeCreepCoinBridge(3,4, owner.address);

    console.log("Finished");

  })
})
