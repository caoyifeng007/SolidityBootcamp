import { ethers, upgrades } from "hardhat";

async function main() {
    const StakeNFT_Factory = await ethers.getContractFactory("StakeNFT");

    const stakeNFT_proxy = await upgrades.deployProxy(StakeNFT_Factory, {
        initializer: "initialize",
        kind: "uups",
    });

    await stakeNFT_proxy.waitForDeployment();

    // StakeNFT contract deployed to: 0x9A676e781A523b5d0C0e43731313A708CB607508
    console.log(
        "StakeNFT contract deployed to:",
        await stakeNFT_proxy.getAddress(),
    );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
