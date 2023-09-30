import { StandardMerkleTree } from "@openzeppelin/merkle-tree";
import fs from "fs";

const ANVIL_ACCOUNT1 = `${process.env.ANVIL_ACC1_ADDR}`;
const ANVIL_ACCOUNT2 = `${process.env.ANVIL_ACC2_ADDR}`;

export function createMerkleTree() {
    const values = [
        // anvil account 0
        [ANVIL_ACCOUNT1, "10", "2"],
        // anvil account 1
        [ANVIL_ACCOUNT2, "25", "9"],
    ];

    const tree = StandardMerkleTree.of(values, [
        "address",
        "uint256",
        "uint256",
    ]);

    console.log("Merkle Root:", tree.root);

    fs.writeFileSync("tree.json", JSON.stringify(tree.dump()));

    return tree.root;
}

export function obtainProof(account: string) {
    const tree = StandardMerkleTree.load(
        JSON.parse(fs.readFileSync("tree.json", "utf8")),
    );

    for (const [i, v] of tree.entries()) {
        if (v[0] === account) {
            const proof = tree.getProof(i);
            console.log("Value:", v);
            console.log("Proof:", proof);

            return { v, proof };
        }
    }
}
