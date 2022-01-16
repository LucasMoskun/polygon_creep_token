const { expect } = require("chai");

const config = require("../config/config.json")
describe("Test Decode poly", function() {
  this.timeout(800000)

  it("Testing decode poly", async function() {

    const owner = await ethers.getSigner(0);
    console.log("Getting ABI...");
    const abi = await ethers.getContractFactory("CreepCoin");
    console.log("Connecting to contract");

    const contractAddress = "0x8693ff62a594802498b04bd7da2a9f190e71ae46";
    const contract = await abi.attach(contractAddress);
    await contract.connect(owner.address);


    //const rootAddress = "0x19583404319c34663C3323467206eFF25FEb3C55";
    //const setRoot = await contract.setFxRootTunnel(rootAddress);
    //console.log("setRoot: ", setRoot);
    //console.log("Reading");

    //const hello = await contract.greet();
    //console.log("hello: ", hello)
    const mint = await contract.mintCreepCoins(1);
    console.log("testReturn: ", mint)
    //const testTokenId = await contract.testReturnTokenId();
    //console.log("testTokenId: ", testTokenId)


  })
})
