import { ethers, upgrades } from "hardhat";

// StakeNFT contract deployed to: 0x9A676e781A523b5d0C0e43731313A708CB607508
const stakeNFT_proxy = "0x9A676e781A523b5d0C0e43731313A708CB607508";
let StakeNFT_Factory;
let stakeNFTv2_proxy;

// after deploy
async function main() {
    StakeNFT_Factory = await ethers.getContractFactory("StakeNFTV2");

    stakeNFTv2_proxy = await upgrades.upgradeProxy(
        stakeNFT_proxy,
        StakeNFT_Factory,
        {
            kind: "uups",
        },
    );

    // StakeNFTV2 upgraded:  0x9A676e781A523b5d0C0e43731313A708CB607508
    console.log("StakeNFTV2 upgraded: ", await stakeNFTv2_proxy.getAddress());

    // Hello Upgradeable StakeNFT token.
    console.log(await stakeNFTv2_proxy.hi());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
