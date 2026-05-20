// script/uploadToIPFS.js
const pinataSDK = require("@pinata/sdk");
const pinata = new pinataSDK(
    process.env.PINATA_API_KEY,
    process.env.PINATA_SECRET
);

async function upload() {
    // Upload images
    const imageResult = await pinata.pinFromFS("./images");
    console.log("Images CID:", imageResult.IpfsHash);

    // Upload metadata
    const metaResult = await pinata.pinFromFS("./metadata");
    console.log("Metadata CID:", metaResult.IpfsHash);
}
upload();