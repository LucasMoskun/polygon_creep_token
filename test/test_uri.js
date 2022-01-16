
const config = require("../config/config.json")
describe("Test Encode Eth", function() {
  this.timeout(800000)

  it("Testing encode eth", async function() {

    const owner = await ethers.getSigner(0);
    console.log("Getting ABI...");
    const abi = await ethers.getContractFactory("AuthorizeCreepCoin");
    console.log("Connecting to contract");

    const contractAddress = "0xb6B48BD8A6cD1267bACF04A1b002335030EA3D6F";
    const contract = await abi.attach(contractAddress);
    await contract.connect(owner.address);

   // const childAddress = "0xaec317cb2990edcf6752234ec0c28fe7c45fe8f1";
   // const setChild = await contract.setFxChildTunnel(childAddress);
   // console.log("setChild: ", setChild);
   // console.log("Authorizing... ");

    //const queryURI = await contract.queryURI("YOOO");

    //const storedURI = await contract.getStoredURI();
    //console.log("Stored URI: ", storedURI);
    const ownerOf = await contract.queryOwner(1);
    console.log("owner of", ownerOf);
    //const authTx = await contract.AuthorizeCreepCoinBridge(3,4, owner.address);

    console.log("Finished");

  })
})
