const { expect } = require("chai");

const config = require("../config/config.json")
describe("Test Decode poly", function() {
  this.timeout(800000)

  it("Testing decode poly", async function() {

    const owner = await ethers.getSigner(0);
    console.log("Getting ABI...");
    const abi = await ethers.getContractFactory("CreepCoin");
    console.log("Connecting to contract");

    const contractAddress = "0xaec317cb2990edcf6752234ec0c28fe7c45fe8f1";
    const contract = await abi.attach(contractAddress);
    await contract.connect(owner.address);

    console.log("Reading");
    const hello = await contract.greet();
    console.log("hello: ", hello)
    const testReturn = await contract.testReturn();
    console.log("testReturn: ", testReturn)
    const testTokenId = await contract.testReturnTokenId();
    console.log("testTokenId: ", testTokenId)


  })
})
