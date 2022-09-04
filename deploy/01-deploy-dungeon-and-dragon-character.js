const { verifyMessage } = require("ethers/lib/utils")
const { network } = require("hardhat")
const { developmentChains, VERIFICATION_BLOCK_CONFIRMATIONS } = require("../helper-hardhat-config")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()

    log("--------------- Deploying Character Contract... ---------------")

    const waitBlockConfirmations = developmentChains.includes(network.name)
        ? 1
        : VERIFICATION_BLOCK_CONFIRMATIONS

    const args = []

    const character = await deploy("DungeonAndDragonCharacter", {
        from: deployer,
        args: args,
        log: true,
        waitConfirmations: waitBlockConfirmations,
    })
    log("--------------- Character Contract deployed! ---------------")

    if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        log("--------------- Verifying! ---------------")
        await verifyMessage(character.address, args)
        log("--------------- Verify process finished! ---------------")
    } else {
        log("--------------- Localhost detected. Nothing to verify ---------------")
    }
}

module.exports.tags = ["all", "character"]
