import { ethers, upgrades } from "hardhat";

// MyUpgradeableNFT  deployed to: 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
const nft_proxy = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";
let NFTV2_Factory;
let nftv2_proxy;

// after deploy
async function main() {
    NFTV2_Factory = await ethers.getContractFactory("MyUpgradeableNFTV2");

    nftv2_proxy = await upgrades.upgradeProxy(nft_proxy, NFTV2_Factory, {
        kind: "uups",
        call: {
            fn: "initialize",
            args: [ethers.encodeBytes32String("Hello World!"), 2],
        },
    });

    //NFTV2 upgraded:  0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
    console.log("NFTV2 upgraded: ", await nftv2_proxy.getAddress());

    //2n
    console.log(await nftv2_proxy.version());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
