const { MerkleTree } = require("merkletreejs");
const keccak256 = require("keccak256");
const whitelist = require("./whitelist.json");

// Step 1 — Hash every address in the whitelist
const leaves = whitelist.map((address) =>
    keccak256(address)
);

// Step 2 — Build the merkle tree from the hashed addresses
const tree = new MerkleTree(leaves, keccak256, {
    sortPairs: true,
});

// Step 3 — Get the root of the tree
const root = tree.getHexRoot();
console.log("============================");
console.log("Merkle Root:", root);
console.log("============================");

// Step 4 — Generate proof for each address
// Each person needs their own proof to mint
whitelist.forEach((address) => {
    const leaf = keccak256(address);
    const proof = tree.getHexProof(leaf);
    console.log(`Address: ${address}`);
    console.log(`Proof: ${JSON.stringify(proof)}`);
    console.log("----------------------------");
});