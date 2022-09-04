const { assert, expect } = require("chai")
const { network, ethers, deployments } = require("hardhat")
const { developmentChains } = require("../helper-hardhat-config")

!developmentChains.includes(network.name)
    ? describe.skip
    : describe("Dungeons and Dragon Character unit test", function () {
          let deployer, character

          beforeEach(async () => {
              accounts = await ethers.getSigners()
              deployer = accounts[0]
              await deployments.fixture["character"]
              character = await ethers.getContract("DungeonAndDragonCharacter")
          })
      })
