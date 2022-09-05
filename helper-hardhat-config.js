const networkConfig = {
    31337: {
        name: "localhost",
        ethUsdPriceFeed: "0x9326BFA02ADD2366b30bacB125260Af641031331",
        gasLane: "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc",
        mintFee: "10000000000000000", // 0.01 ETH
        callBackGasLimit: "500000", // 500,000 gas
    },
    // Price Feed Address, values can be obtained at https://docs.chain.link/docs/reference-contracts
    // Data related to VRF Randoms request on https://docs.chain.link/docs/vrf/v2/supported-networks/
    4: {
        name: "rinkeby",
        ethUsdPriceFeed: "0x8A753747A1Fa494EC906cE90E9f37563A8AF630e",
        vrfCoordinatorV2: "0x6168499c0cFfCaCD319c818142124B7A15E857ab",
        gasLane: "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc", //gwei
        mintFee: "10000000000000000", // 0.01 ETH
        callBackGasLimit: "500000", // 500,000 gas
        LINK_token: "0x01BE23585060835E02B77ef475b0Cc51aA1e0709",
    },
    5: {
        name: "goerli",
        ethUsdPriceFeed: "0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e",
        vrfCoordinatorV2: "0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D",
        gasLane: "0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15",
        mintFee: "10000000000000000", // 0.01 ETH
        callBackGasLimit: "500000", // 500,000 gas
        LINK_token: "0x326C977E6efc84E512bB9C30f76E30c160eD06FB",
    },
}

const DECIMALS = "18"
const INITIAL_PRICE = "200000000000000000000"
const BASE_FEE = "250000000000000000"
const GAS_PRICE_LINK = 1e9
const VERIFICATION_BLOCK_CONFIRMATIONS = 6
const FUND_AMOUNT = "1000000000000000000000"
const developmentChains = ["hardhat", "localhost"]

module.exports = {
    networkConfig,
    DECIMALS,
    INITIAL_PRICE,
    BASE_FEE,
    GAS_PRICE_LINK,
    FUND_AMOUNT,
    VERIFICATION_BLOCK_CONFIRMATIONS,
    developmentChains,
}
