import { ethers, upgrades } from "hardhat";

import { createMerkleTree, obtainProof } from "./utils/merkle-tree-utils";

const account = `${process.env.ANVIL_ACC1_ADDR}`;
let treeRoot = createMerkleTree();
let { proof } = obtainProof(account) as any;

async function main() {
    const NFT_Factory = await ethers.getContractFactory("MyUpgradeableNFT");

    const nft_proxy = await upgrades.deployProxy(NFT_Factory, [treeRoot], {
        initializer: "initialize",
        kind: "uups",
    });

    await nft_proxy.waitForDeployment();

    // MyUpgradeableNFT  deployed to: 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
    console.log("MyUpgradeableNFT  deployed to:", await nft_proxy.getAddress());

    await nft_proxy.presaleMint(account, "10", "2", proof, {
        value: ethers.parseEther("0.0005"),
    });

    console.log(await nft_proxy.balanceOf(account));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
