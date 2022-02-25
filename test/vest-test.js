const { inputToConfig } = require("@ethereum-waffle/compiler");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Vest", function () {
  let TestCoin;
  let testCoin;

  let Vest;
  let vest;

  let accounts;
  let owner;
  let beneficiary;

  beforeEach(async () => {
    accounts = await ethers.getSigners();
    owner = accounts[0];
    beneficiary = accounts[1];

    Vest = await ethers.getContractFactory("Vest");
    vest = await Vest.deploy(owner.address, beneficiary.address, 864000, 86400, false) // 10 days duration, 1 day cliff
    await vest.deployed();

    TestCoin = await ethers.getContractFactory("TestCoin");
    testCoin = await TestCoin.deploy(vest.address); // mints 100,000 coints to the vesting contract to test out (assume this is how many syn tokens the employee gets)
    await testCoin.deployed();

  })

  describe("vesting functionality", function() {
    it("should vest all tokens if after duration", async() => {
      // increase time by 11 days
      await ethers.provider.send("evm_increaseTime", [86400 * 11])
      await ethers.provider.send("evm_mine")
  
      await vest.releaseToken(testCoin.address) // vest all tokens
      let balance = await testCoin.balanceOf(beneficiary.address);
  
      expect(ethers.utils.formatEther(balance)).to.eq("100000.0")
    })
  
    it("should not vest any tokens if it is before the cliff", async() => {
      await vest.releaseToken(testCoin.address) // vest all tokens
      let balance = await testCoin.balanceOf(beneficiary.address);
  
      expect(ethers.utils.formatEther(balance)).to.eq("0.0")
    })
  
    it("should vest part of the tokens linearlly", async() => {
      await ethers.provider.send("evm_increaseTime", [86400 * 5])
      await ethers.provider.send("evm_mine")
  
      await vest.releaseToken(testCoin.address) // vest all tokens
      let balance = await testCoin.balanceOf(beneficiary.address);
  
      console.log(balance)
    })
  })

  describe("revoke functionality", function() {
    
  })

});
