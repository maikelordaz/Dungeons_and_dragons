const { network, ethers } = require("hardhat")
const { verify } = require("../utils/verify")
const { developmentChains, FUND_AMOUNT, networkConfig } = require("../helper-hardhat-config")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId
    let vrfCoordinatorV2Address, subscriptionId

    if (chainId == 31337) {
        const vrfCoordinatorV2Mock = await ethers.getContract("VRFCoordinatorV2Mock")
        vrfCoordinatorV2Address = vrfCoordinatorV2Mock.address
        const txResponse = await vrfCoordinatorV2Mock.createSubscription()
        const txReceipt = await txResponse.wait(1)
        subscriptionId = txReceipt.events[0].args.subId
        await vrfCoordinatorV2Mock.fundSubscription(subscriptionId, FUND_AMOUNT)
    } else {
        vrfCoordinatorV2Address = networkConfig[chainId].vrfCoordinatorV2
        subscriptionId = networkConfig[chainId].subscriptionId
    }

    log("--------------- Deploying Dungeons And Dragons Contract... ---------------")

    const waitBlockConfirmations = developmentChains.includes(network.name)
        ? 1
        : network.chainId.blockConfirmations

    const args = [
        vrfCoordinatorV2Address,
        networkConfig[chainId]["gasLane"],
        subscriptionId,
        networkConfig[chainId]["callBackGasLimit"],
        networkConfig[chainId]["mintFee"],
    ]

    const dungeonsAndDragons = await deploy("DungeonsAndDragons", {
        from: deployer,
        args: args,
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })
    log("--------------- Dungeons And Dragons Contract deployed! ---------------")

    if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        log("--------------- Verifying! ---------------")
        await verify(dungeonsAndDragons.address, args)
        log("--------------- Verify process finished! ---------------")
    } else {
        log("--------------- Localhost detected. Nothing to verify ---------------")
    }
}

module.exports.tags = ["all", "dungeon", "main"]
