// script/Interactions.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {NftAgain} from "../src/NftAgain.sol";
import {console} from "forge-std/console.sol";

contract OpenWhitelistSale is Script {
    function run() external {
        address contractAddress = vm.envAddress("CONTRACT_ADDRESS");

        vm.startBroadcast();
        NftAgain nft = NftAgain(contractAddress);
        nft.setSaleState(NftAgain.SaleState.Whitelist);
        vm.stopBroadcast();

        console.log("Whitelist sale opened");
    }
}

contract OpenPublicSale is Script {
    function run() external {
        address contractAddress = vm.envAddress("CONTRACT_ADDRESS");

        vm.startBroadcast();
        NftAgain nft = NftAgain(contractAddress);
        nft.setSaleState(NftAgain.SaleState.Public);
        vm.stopBroadcast();

        console.log("Public sale opened");
    }
}

contract RevealCollection is Script {
    function run() external {
        address contractAddress = vm.envAddress("CONTRACT_ADDRESS");
        string memory baseUri = vm.envString("BASE_URI");

        vm.startBroadcast();
        NftAgain nft = NftAgain(contractAddress);
        nft.reveal(baseUri);
        vm.stopBroadcast();

        console.log("Collection revealed with URI:", baseUri);
    }
}

contract SetMerkleRoot is Script {
    function run() external {
        address contractAddress = vm.envAddress("CONTRACT_ADDRESS");
        bytes32 merkleRoot = vm.envBytes32("MERKLE_ROOT");

        vm.startBroadcast();
        NftAgain nft = NftAgain(contractAddress);
        nft.setMerkleRoot(merkleRoot);
        vm.stopBroadcast();

        console.log("Merkle root set");
    }
}

contract WithdrawFunds is Script {
    function run() external {
        address contractAddress = vm.envAddress("CONTRACT_ADDRESS");

        vm.startBroadcast();
        NftAgain nft = NftAgain(contractAddress);
        nft.withdraw();
        vm.stopBroadcast();

        console.log("Funds withdrawn");
    }
}

contract UpdateMintPrice is Script {
    function run() external {
        address contractAddress = vm.envAddress("CONTRACT_ADDRESS");
        uint256 newPrice = vm.envUint("NEW_MINT_PRICE");

        vm.startBroadcast();
        NftAgain nft = NftAgain(contractAddress);
        nft.setMintPrice(newPrice);
        vm.stopBroadcast();

        console.log("Mint price updated to:", newPrice);
    }
}
