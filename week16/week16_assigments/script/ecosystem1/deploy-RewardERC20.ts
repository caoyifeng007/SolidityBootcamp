import { ethers, upgrades } from "hardhat";

async function main() {
    const ERC20_Factory = await ethers.getContractFactory("RewardERC20Token");

    const erc20_proxy = await upgrades.deployProxy(ERC20_Factory, {
        initializer: "initialize",
        kind: "uups",
    });

    await erc20_proxy.waitForDeployment();

    // ERC20 contract deployed to: 0x0165878A594ca255338adfa4d48449f69242Eb8F
    console.log("ERC20 contract deployed to:", await erc20_proxy.getAddress());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
