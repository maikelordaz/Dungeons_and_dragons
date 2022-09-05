const { network } = require("hardhat")
const { BASE_FEE, GAS_PRICE_LINK } = require("../helper-hardhat-config")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId
    if (chainId == 31337) {
        log("--------------- Local network detected ---------------")
        log("--------------- Deploying needed Mocks... ---------------")
        log("--------------- Deploying VRF Coordinator V2 Mock... ---------------")

        const args = [BASE_FEE, GAS_PRICE_LINK]
        await deploy("VRFCoordinatorV2Mock", {
            from: deployer,
            log: true,
            args: args,
        })
        log("--------------- VRF Coordinator V2 Mock deployed! ---------------")
        log("--------------- All needed Mocks deployed! ---------------")
    }
}

module.exports.tags = ["all", "mocks", "main"]
