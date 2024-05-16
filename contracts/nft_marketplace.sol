// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract NFTMarketplace is ERC721URIStorage {
    address payable contractOwner;
    uint public listingPrice = 10000000 wei;

    struct NFT {
        uint id;
        address payable contractAddress;
        address payable owner;
        uint price;
        uint totalNFTs;
    }

    Counters.Counter private _nftIds;
    mapping(uint => NFT) private _idToNFT;

    event NFTListed(
        uint indexed id,
        address payable contractAddress,
        address payable owner,
        uint price
    );

    constructor() ERC721("EducativeNFT", "EDUNFT") {
        contractOwner = payable(msg.sender);
    }

    function mintNFT(string memory _tokenURI, uint price) external payable {
        uint nftId = Counters.current(_nftIds);

        require(
            msg.value >= listingPrice,
            "Insufficient funds sent"
        );

        _safeMint(msg.sender, nftId);
        _setTokenURI(nftId, _tokenURI);

        NFT storage newNFT = _idToNFT[nftId];

        newNFT.contractAddress = payable(address(this));
        newNFT.owner = payable(msg.sender);
        newNFT.price = price;

        (bool transferFeeSuccess, ) = payable(contractOwner).call{
            value: listingPrice
        }("");

        require(
            transferFeeSuccess,
            "Failed to transfer listing fee to the owner"
        );

        emit NFTListed(
            nftId,
            payable(address(this)),
            payable(msg.sender),
            price
        );

        Counters.increment(_nftIds);
    }

    function getAllNFTs() external view returns (NFT[] memory) {
        uint totlaItemCount = Counters.current(_nftIds);
        NFT[] memory items = new NFT[](totlaItemCount);

        for (uint i = 0; i < totlaItemCount; i++) {
            NFT storage currentItem = _idToNFT[i];
            items[i] = currentItem;
        }

        return items;
    }

    function getMyNfts() external view returns (NFT[] memory) {
        uint totlaItemCount = Counters.current(_nftIds);
        uint totalMyNfts = 0;

        for (uint i = 0; i < totlaItemCount; i++) {
            if (_idToNFT[i].owner == msg.sender) totalMyNfts += 1;
        }

        NFT[] memory items = new NFT[](totalMyNfts);
        uint itemIndex = 0;

        for (uint i = 0; i < totlaItemCount; i++) {
            if (_idToNFT[i].owner == msg.sender) {
                NFT storage currentItem = _idToNFT[i];
                items[itemIndex] = currentItem;
                itemIndex++;
            }
        }

        return items;
    }

    function buyNFT(uint id) external payable {
        require(id < Counters.current(_nftIds), "The Provided nft not exit");
        uint256 price = _idToNFT[id].price;
        address payable seller = _idToNFT[id].owner;

        require(msg.value == price, "Incorrect payment amount");

        (bool transferNFTPriceSuccess, ) = payable(seller).call{value: msg.value}(
            ""
        );

        require(
            transferNFTPriceSuccess,
            "Transfering ETH failed"
        );

        _idToNFT[id].owner = payable(msg.sender);
        _transfer(seller, msg.sender, id);
    }
}
