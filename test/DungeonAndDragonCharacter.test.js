const { assert, expect } = require("chai")
const { network, ethers, deployments } = require("hardhat")
const { developmentChains, FUND_AMOUNT } = require("../helper-hardhat-config")

!developmentChains.includes(network.name)
    ? describe.skip
    : describe("Dungeons and Dragons unit test", function () {
          let deployer, dungeons, vrfCoordinatorV2Mock, subscriptionId
          const name = "GOKU"

          beforeEach(async () => {
              accounts = await ethers.getSigners()
              deployer = accounts[0]
              await deployments.fixture(["mocks", "dungeon"])
              dungeons = await ethers.getContract("DungeonsAndDragons")
              vrfCoordinatorV2Mock = await ethers.getContract("VRFCoordinatorV2Mock")
              const subscriptionTxResponse = await vrfCoordinatorV2Mock.createSubscription()
              const subscrtiptionTxReceipt = await subscriptionTxResponse.wait(1)
              subscriptionId = subscrtiptionTxReceipt.events[0].args.subId
              await vrfCoordinatorV2Mock.fundSubscription(subscriptionId, FUND_AMOUNT)
          })

          describe("constructor", () => {
              it("set starting values correctly", async function () {
                  const mintFee = await dungeons.getMintFee()
                  const expectedFee = "10000000000000000"
                  assert.equal(mintFee.toString(), expectedFee)
              })
          })

          describe("requestRandomCharacter", () => {
              it("fails if payment is't enough", async function () {
                  await expect(dungeons.requestRandomCharacter(name)).to.be.revertedWith(
                      "DungeonsAndDragons__NeedMoreEth"
                  )
              })

              it("emits an event and kicks off a random word request", async function () {
                  const fee = await dungeons.getMintFee()
                  await expect(
                      dungeons.requestRandomCharacter(name, { value: fee.toString() })
                  ).to.emit(dungeons, "characterRequested")
              })
          })
      })
