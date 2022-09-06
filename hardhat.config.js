require("hardhat-deploy")
require("dotenv").config()
require("solidity-coverage")
require("hardhat-gas-reporter")
require("hardhat-contract-sizer")
require("@nomiclabs/hardhat-waffle")
require("@nomiclabs/hardhat-etherscan")

const PRIVATE_KEY = process.env.PRIVATE_KEY
const GOERLI_RPC_URL = process.env.GOERLI_RPC_URL
const RINKEBY_RPC_URL = process.env.RINKEBY_RPC_URL
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY
const COINMARKETCAP_API_KEY = process.env.COINMARKETCAP_API_KEY

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
    solidity: {
        compilers: [
            {
                version: "0.8.8",
            },
        ],
    },
    defaultNetwork: "hardhat",
    networks: {
        hardhat: {
            chainId: 31337,
            blockConfirmations: 1,
        },
        localhost: {
            chainId: 31337,
        },
        rinkeby: {
            chainId: 4,
            accounts: [PRIVATE_KEY],
            url: RINKEBY_RPC_URL,
            blockConfirmations: 6,
        },
        goerli: {
            chainId: 5,
            accounts: [PRIVATE_KEY],
            url: GOERLI_RPC_URL,
            blockConfirmations: 6,
        },
    },
    etherscan: {
        apiKey: ETHERSCAN_API_KEY,
    },
    gasReporter: {
        enabled: false,
        currency: "USD",
        outputFile: "gas-report.txt",
        noColors: true,
        coinmarketcap: COINMARKETCAP_API_KEY,
    },
    namedAccounts: {
        deployer: {
            default: 0,
        },
        Alice: {
            default: 1,
        },
        Bob: {
            default: 2,
        },
    },
    mocha: {
        timeout: 300000,
    },
}
