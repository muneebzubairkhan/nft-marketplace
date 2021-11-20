// Hi. If you have any questions or comments in this smart contract please let me know at:
// Whatsapp +923014440289, Telegram @thinkmuneeb, discord: timon#1213, I'm Muneeb Zubair Khan
//
//
// Smart Contract Made by Muneeb Zubair Khan <muneeb.zubair.hash@gmail.com>
// The UI is made by Abraham Peter, Whatsapp +923004702553, Telegram @Abrahampeterhash.
//
//
//
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract CheekyLionClub is ERC721("Cheeky Lion Club", "CLC") {
    uint256 circulatingSupply;

    constructor() {
        _mint(msg.sender, ++circulatingSupply);
        _mint(msg.sender, ++circulatingSupply);
    }
}

contract Marketplace is ERC721("ART", "ART") {
    // balances of people
    // mapping(address => uint256) public balance;

    // buying selling functionality
    // start
    address public sellerAddress = address(0);
    uint256 public sellingPrice = 0;
    uint256 public tokenID = 0;
    address public sellNftAddress = address(0);

    function buyNft() external payable {
        require(sellerAddress != address(0), "sale is not active");
        require(msg.value >= sellingPrice, "please send more money");
        require(msg.sender != sellerAddress, "owner can not buy");

        IERC721(sellNftAddress).transferFrom(
            sellerAddress,
            msg.sender,
            tokenID
        );
    }

    function sellNft(
        uint256 _sellingPrice,
        uint256 _tokenID,
        address _sellNftAddress
    ) public {
        bool isApproved = IERC721(_sellNftAddress).isApprovedForAll(
            msg.sender,
            address(this)
        );
        require(
            isApproved,
            "Please approve Marketplace smart contract to send your NFT to buyer."
        );
        address _owner = IERC721(_sellNftAddress).ownerOf(_tokenID);
        require(msg.sender == _owner, "you are not owner");

        sellerAddress = msg.sender;
        sellingPrice = _sellingPrice;
        tokenID = _tokenID;
        sellNftAddress = _sellNftAddress;
    }

    // end

    // bidding, do bid, accept bid, reject bid
    // start
    uint256 public lastBidPrice;
    address public lastBidder;

    function bid(uint256 _price) external {
        bool isApproved = IERC721(sellNftAddress).isApprovedForAll(
            msg.sender,
            address(this)
        );
        require(
            isApproved,
            "Please approve Marketplace smart contract to spend your NFT."
        );
        require(_price > lastBidPrice, "Please bid more than last bid.");
        lastBidPrice = _price;
        lastBidder = msg.sender;
    }

    function acceptBid() external {
        require(lastBidder != address(0), "There is no bidder.");
        IERC721(sellNftAddress).transferFrom(msg.sender, lastBidder, tokenID);
    }

    // end

    // mint functionality. convert art into NFTs.
    // start
    mapping(uint256 => string) public _tokenURIs;
    uint256 public circulatingSupply;

    function mint(string memory _uri, uint256 _sellingPrice) external {
        sellNft(_sellingPrice, ++circulatingSupply, address(this));
        _tokenURIs[circulatingSupply] = _uri;
        _mint(msg.sender, circulatingSupply);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        return _tokenURIs[tokenId];
    }
    // end
}
