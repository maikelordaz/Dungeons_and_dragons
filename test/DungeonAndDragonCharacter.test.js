const { assert, expect } = require("chai")
const { network, ethers, deployments } = require("hardhat")
const { resolve } = require("path")
const { developmentChains, FUND_AMOUNT } = require("../helper-hardhat-config")

!developmentChains.includes(network.name)
    ? describe.skip
    : describe("Dungeons and Dragons unit test", function () {
          let deployer, dungeons, vrfCoordinatorV2Mock, subscriptionId
          const name = "GOKU"

          beforeEach(async () => {
              accounts = await ethers.getSigners()
              deployer = accounts[0]
              Alice = accounts[1]
              Bob = accounts[2]
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

          describe("mintCharacter", () => {
              it("fails if payment isn't enough", async function () {
                  await expect(dungeons.mintCharacter(name)).to.be.revertedWith(
                      "DungeonsAndDragons__NeedMoreEth"
                  )
              })

              it("emits an event and kicks off a random word request", async function () {
                  const fee = await dungeons.getMintFee()
                  await expect(dungeons.mintCharacter(name, { value: fee.toString() })).to.emit(
                      dungeons,
                      "characterRequested"
                  )
              })
          })

          it("Should mint a character", async function () {
              await new Promise(async (resolve, reject) => {
                  dungeons.once("characterMinted", async () => {
                      try {
                          const finalNumberOfCharacters = await dungeons.getNumberOfCharacters()
                          const leveOfGoku = await dungeons.getLevel(0)
                          const gokuOverview = await dungeons.getCharacterName(0)
                          const gokuStats = await dungeons.getCharacterStats(0)
                          assert.equal(gokuOverview, name)
                          expect(leveOfGoku).to.exist
                          expect(gokuStats[0]).to.exist
                          expect(gokuStats[1]).to.exist
                          expect(gokuStats[2]).to.exist
                          expect(gokuStats[3]).to.exist
                          expect(gokuStats[4]).to.exist
                          expect(gokuStats[5]).to.exist
                          expect(gokuStats[6]).to.exist
                          assert(finalNumberOfCharacters > initialNumberOfCharacters)
                          resolve()
                      } catch (e) {
                          reject(e)
                      }
                  })

                  const initialNumberOfCharacters = await dungeons.getNumberOfCharacters()
                  const fee = await dungeons.getMintFee()
                  const requestTx = await dungeons.mintCharacter(name, {
                      value: fee.toString(),
                  })

                  const requestTxReceipt = await requestTx.wait(1)
                  await vrfCoordinatorV2Mock.fulfillRandomWords(
                      requestTxReceipt.events[1].args.requestId,
                      dungeons.address
                  )
              })
          })

          describe("withdraw function", () => {
              it("Withdraw the money from minting characters", async function () {
                  const deployerInitialBalance = await deployer.getBalance()
                  const alice = dungeons.connect(Alice)
                  const bob = dungeons.connect(Bob)
                  const fee = await dungeons.getMintFee()
                  await alice.mintCharacter("Alice", { value: fee.toString() })
                  await bob.mintCharacter("Bob", { value: fee.toString() })
                  await dungeons.withdraw()
                  const deployerFinalBalance = await deployer.getBalance()
              })
          })
      })
