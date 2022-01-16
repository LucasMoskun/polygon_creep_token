const { expect } = require("chai");

const config = require("../config/config.json")
describe("Test Decode poly", function() {
  this.timeout(800000)

  it("Testing decode poly", async function() {

    const owner = await ethers.getSigner(0);
    console.log("Getting ABI...");
    const abi = await ethers.getContractFactory("CreepCoin");
    console.log("Connecting to contract");

    const contractAddress = "0x0ece8a8ba0a6ec83ff51ba70d2af6955b3178d5c";
    const contract = await abi.attach(contractAddress);
    await contract.connect(owner.address);


    const rootAddress = "0x672C4838c6642e7125d9F0024b38F033238C0Ddd";
    const setRoot = await contract.setFxRootTunnel(rootAddress);
    console.log("setRoot: ", setRoot);
    //console.log("Reading");

    //const hello = await contract.greet();
    //console.log("hello: ", hello)
    //const mint = await contract.mintCreepCoins(1);
    //console.log("testReturn: ", mint)
    //const testTokenId = await contract.testReturnTokenId();
    //console.log("testTokenId: ", testTokenId)


  })
})
