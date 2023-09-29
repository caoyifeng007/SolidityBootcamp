import { ethers, upgrades } from "hardhat";

async function main() {
    const NFT_Factory = await ethers.getContractFactory("MyUpgradeableNFT");

    const nft_proxy = await upgrades.deployProxy(
        NFT_Factory,
        [ethers.encodeBytes32String("Hello World!")],
        {
            initializer: "initialize",
            kind: "uups",
        },
    );

    await nft_proxy.waitForDeployment();

    // MyUpgradeableNFT  deployed to: 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
    console.log("MyUpgradeableNFT  deployed to:", await nft_proxy.getAddress());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
