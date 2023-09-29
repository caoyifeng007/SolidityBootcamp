import { ethers, upgrades } from "hardhat";

// ERC20 contract deployed to: 0x0165878A594ca255338adfa4d48449f69242Eb8F
const erc20_proxy = "0x0165878A594ca255338adfa4d48449f69242Eb8F";
let ERC20_Factory;
let erc20v2_proxy;

// after deploy
async function main() {
    ERC20_Factory = await ethers.getContractFactory("RewardERC20TokenV2");

    erc20v2_proxy = await upgrades.upgradeProxy(erc20_proxy, ERC20_Factory, {
        kind: "uups",
    });

    // ERC20V2 upgraded:  0x0165878A594ca255338adfa4d48449f69242Eb8F
    console.log("ERC20V2 upgraded: ", await erc20v2_proxy.getAddress());

    // Hello Upgradeable ERC20 token.
    console.log(await erc20v2_proxy.hi());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
