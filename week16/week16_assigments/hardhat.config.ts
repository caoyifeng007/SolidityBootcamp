import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

// https://hardhat.org/hardhat-runner/docs/advanced/hardhat-and-foundry#adding-hardhat-to-a-foundry-project
// Integrating Hardhat into Foundry project
import "@nomicfoundation/hardhat-foundry";
import "@openzeppelin/hardhat-upgrades";
import "@nomicfoundation/hardhat-verify";

const config: HardhatUserConfig = {
    solidity: "0.8.19",
    defaultNetwork: "sepolia",
    networks: {
        // hardhat: {},
        anvil: {
            url: "http://127.0.0.1:8545",
            // needs `dotenv` to use this syntax
            accounts: [`${process.env.ANVIL_ACC1_PK}`],
        },
        gorli: {
            url: `${process.env.ALCHEMY_GOERLI_KEY}`,
            accounts: [`${process.env.METAMASK_ACC5_PK}`],
        },
        sepolia: {
            url: `${process.env.ALCHEMY_SEPOLIA_KEY}`,
            accounts: [`${process.env.METAMASK_ACC5_PK}`],
        },
    },
    etherscan: {
        apiKey: `${process.env.ETHERSCAN_API_KEY}`,
    },
};

export default config;
