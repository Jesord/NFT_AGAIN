// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {NftAgain} from "../src/NftAgain.sol";

contract DeployNftAgain is Script {
    function run() external {
        string memory unrevealedURI = "ipfs://QmUnrevealedURI";

        vm.startBroadcast(); // Uses --account flag

        NftAgain nftAgain = new NftAgain(0.000005 ether, 10, unrevealedURI);

        vm.stopBroadcast();

        console.log("========================");
        console.log("NFT Deployed Successfully!");
        console.log("Contract Address:", address(nftAgain));
        console.log("Deployed by:", msg.sender);
        console.log("========================");
    }
}
