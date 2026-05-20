// script/generateMetadata.js
const fs = require("fs");

for (let i = 1; i <= 100; i++) {
    const metadata = {
        name: `Cannon #${i}`,
        description: "A Cannon NFT",
        image: `ipfs://YourImagesCID/${i}.png`,
        attributes: [
            { trait_type: "Background", value: "Blue" },
            { trait_type: "Eyes", value: "Laser" },
        ]
    };
    fs.writeFileSync(
        `./metadata/${i}.json`,
        JSON.stringify(metadata, null, 2)
    );
}