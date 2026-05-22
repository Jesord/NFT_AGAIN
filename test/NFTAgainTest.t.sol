//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Test} from "forge-std/Test.sol";
import {NftAgain} from "../src/NftAgain.sol";

contract NFTAgainTest is Test {
    NftAgain public nft;

    address public owner = makeAddr("owner");
    address public otherUser = makeAddr("otherUser");

    uint256 public constant _mintPrice = 0.005 ether;
    string public constant Token_URI = "ipfs://QmTest/1.json";

    string public constant UNREVEALED_URI = "ipfs://QmUnrevealedURI";

    event Minted(address indexed to, uint256 tokenId, string tokenUri);

    function setUp() public {
        vm.prank(owner);
        nft = new NftAgain(_mintPrice, 100, UNREVEALED_URI);
        vm.deal(otherUser, 5 ether);

        // ✅ Open public sale — without this every mintNft call reverts
        vm.prank(owner);
        nft.setSaleState(NftAgain.SaleState.Public);
    }

    function test_RevertIf_MaxSupplyReached() public {
        uint256 maxSupply = nft.MAX_SUPPLY();
        for (uint256 i = 0; i < maxSupply; i++) {
            address minter = address(uint160(uint256(keccak256(abi.encodePacked("minter", i)))));
            vm.deal(minter, _mintPrice);
            vm.prank(minter);
            nft.mintNft{value: _mintPrice}(minter, 1, Token_URI);
        }

        vm.expectRevert("Max supply reached");
        vm.prank(otherUser);
        nft.mintNft{value: _mintPrice}(otherUser, 1, Token_URI);
    }

    function test_RevertIf_InsufficientPayment() public {
        uint256 lowPayment = _mintPrice - 0.002 ether;

        vm.prank(otherUser);
        vm.expectRevert();
        nft.mintNft{value: lowPayment}(otherUser, 1, Token_URI);
    }

    function testFuzz_MintSucceedWithSufficientPayment(uint256 payment) public {
        payment = bound(payment, _mintPrice, 0.1 ether);
        vm.deal(otherUser, payment);

        vm.prank(otherUser);
        uint256 tokenId = nft.mintNft{value: payment}(otherUser, 1, Token_URI);

        assertEq(nft.ownerOf(tokenId), otherUser);
    }

    function test_TokenIdIncrementsOnEachMint() public {
        vm.prank(otherUser);
        uint256 firstTokenId = nft.mintNft{value: _mintPrice}(otherUser, 1, Token_URI);

        address anotherUser = makeAddr("anotherUser");
        vm.deal(anotherUser, _mintPrice);
        vm.prank(anotherUser);

        uint256 secondTokenId = nft.mintNft{value: _mintPrice}(anotherUser, 1, Token_URI);
        assertEq(firstTokenId, 1);
        assertEq(secondTokenId, 2);
    }

    function test_RevertIf_NonOwnerSetsTokenURI() public {
        // Mint a token first
        vm.prank(otherUser);
        uint256 tokenId = nft.mintNft{value: _mintPrice}(otherUser, 1, Token_URI);

        string memory newUri = "ipfs://QmNewHash/1.json";

        // otherUser tries to set the URI — should revert
        vm.prank(otherUser);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", otherUser));
        nft.setTokenURI(tokenId, newUri);
    }
}
