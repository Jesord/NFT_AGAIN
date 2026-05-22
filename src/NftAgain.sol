//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {ERC2981} from "@openzeppelin/contracts/token/common/ERC2981.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract NftAgain is ERC721, ERC721URIStorage, Ownable, ReentrancyGuard, ERC2981 {
    uint256 public constant MAX_SUPPLY = 100;
    uint256 private _nextTokenId;
    uint256 public _mintPrice;
    uint256 public whitelistMintPrice;

    uint256 public maxPerWallet = 4;

    //Add - reveal mechanism
    bool public revealed = false;
    string public baseURI;
    string public notRevealedURI;

    //sales state
    enum SaleState {
        Closed,
        Whitelist,
        Public
    }
    SaleState public saleState = SaleState.Closed;

    event withdrawn(address indexed owner, uint256 amount);
    event Minted(address indexed to, uint256 tokenId, string tokenUri);
    event saleStateChanged(SaleState state);
    event TokenURIUpdated(uint256 indexed tokenId, string newTokenUri);
    event Revealed(string baseURI);

    mapping(uint256 => string) private _tokenUris;
    mapping(address => uint256) public mintedPerWallet;
    mapping(address => bool) public whitelistClaimed;
    bytes32 public merkleRoot;

    constructor(uint256 mintPrice, uint256 _whitelistMintPrice, string memory _unrevealedURI)
        ERC721("Cannon", "DULL_C")
        Ownable(msg.sender)
    {
        _mintPrice = mintPrice;
        whitelistMintPrice = _whitelistMintPrice;
        notRevealedURI = _unrevealedURI;

        //Adding Royalties for the owner on every secondary sales 2%
        _setDefaultRoyalty(msg.sender, 200); // 2% royalty
    }

    function whitelistMint(uint256 amount, bytes32[] calldata proof) external payable {
        require(saleState == SaleState.Whitelist, "Whitelist mint not open");
        require(!whitelistClaimed[msg.sender], "Already claimed");
        require(MerkleProof.verify(proof, merkleRoot, keccak256(abi.encodePacked(msg.sender))), "Invalid proof");
        require(msg.value >= whitelistMintPrice * amount, "Insufficient payment");
        require(mintedPerWallet[msg.sender] + amount <= maxPerWallet, "Exceeds wallet limit");

        whitelistClaimed[msg.sender] = true;
        _mintTokens(msg.sender, amount);
    }

    function mintNft(
        address to,
        uint256 amount,
        string memory //tokenUri
    )
        external
        payable
        returns (uint256 tokenId)
    {
        require(saleState == SaleState.Public, "Public sale is not activated");
        require(_nextTokenId + amount <= MAX_SUPPLY, "Max supply reached");
        require(msg.value >= _mintPrice * amount, "NOT ENOUGH ETH ");
        require(mintedPerWallet[msg.sender] + amount <= maxPerWallet, "Exceeds wallet limit");

        mintedPerWallet[msg.sender] += amount;
        return _mintTokens(to, amount);
    }

    function _mintTokens(address to, uint256 amount) internal returns (uint256 lastTokenId) {
        for (uint256 i = 0; i < amount; i++) {
            _nextTokenId++;
            _safeMint(to, _nextTokenId);
            emit Minted(to, _nextTokenId, tokenURI(_nextTokenId));
        }
        return _nextTokenId;
    }

    function reveal(string memory _baseURI) public onlyOwner {
        baseURI = _baseURI;
        revealed = true;
        emit Revealed(_baseURI);
    }

    function tokenURI(uint256 tokenId) public view virtual override(ERC721, ERC721URIStorage) returns (string memory) {
        if (!revealed) {
            return notRevealedURI;
        }
        return super.tokenURI(tokenId);
    }

    function setTokenURI(uint256 tokenId, string memory _tokenUri) public onlyOwner {
        _setTokenURI(tokenId, _tokenUri);
        emit TokenURIUpdated(tokenId, _tokenUri);
    }

    function setSaleState(SaleState _state) public onlyOwner {
        saleState = _state;
        emit saleStateChanged(_state);
    }

    function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function setMintPrice(uint256 mintPrice) public onlyOwner {
        _mintPrice = mintPrice;
    }

    function setMaxPerWallet(uint256 _max) public onlyOwner {
        maxPerWallet = _max;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, ERC721URIStorage, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    // function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
    //     require(ownerOf(tokenId) == from, "Owner does not match");
    //     require(ownerOf(tokenId) != address(0), "Token not available");

    function withdraw() public onlyOwner nonReentrant {
        uint256 amount = address(this).balance;
        require(amount > 0, "Not Enough Funds");
        (bool success,) = payable(owner()).call{value: amount}("");
        require(success, "Withdrawal Failed");

        emit withdrawn(owner(), amount);
    }
}
