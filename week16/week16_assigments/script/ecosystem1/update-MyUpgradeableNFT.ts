import { ethers, upgrades } from "hardhat";

import { createMerkleTree } from "./utils/merkle-tree-utils";

const account = `${process.env.ANVIL_ACC1_ADDR}`;
const account2 = `${process.env.ANVIL_ACC2_ADDR}`;
let treeRoot = createMerkleTree();

// MyUpgradeableNFT  deployed to: 0x5FC8d32690cc91D4c39d9d3abcBD16989F875707
const nft_proxy = "0x5FC8d32690cc91D4c39d9d3abcBD16989F875707";
let NFTV2_Factory;
let nftv2_proxy;

// after deploy
async function main() {
    NFTV2_Factory = await ethers.getContractFactory("MyUpgradeableNFTV2");

    nftv2_proxy = await upgrades.upgradeProxy(nft_proxy, NFTV2_Factory, {
        kind: "uups",
        call: {
            fn: "initialize",
            args: [treeRoot, 2],
        },
    });

    //NFTV2 upgraded:  0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
    console.log("NFTV2 upgraded: ", await nftv2_proxy.getAddress());

    //2n
    console.log(await nftv2_proxy.version());

    await nftv2_proxy.mint(account, 99, { value: ethers.parseEther("0.001") });

    await nftv2_proxy.transferByGod(account, account2, 99);

    console.log(await nftv2_proxy.balanceOf(account2));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
