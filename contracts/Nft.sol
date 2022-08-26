//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Nft is ERC721, Ownable {
    uint256 public mintPrice;
    uint256 public totalSupply; // current num of nft while you are minting
    uint256 public maxSupply; // max num of nft that will be in the collection
    uint256 public maxPerWallet;
    bool public isPublicMintEnabled; // when users can mint, owner will be able to toggle
    string internal baseTokenUri; // determine the url of which OS can use to determine where the is located
    address payable public withdrawWallet;
    mapping(address => uint256) public walletMints; // keep track each wallet has minted

    constructor() payable ERC721("NftProject", "NftProject") {
        mintPrice = 0.02 ether;
        totalSupply = 0;
        maxSupply = 1000;
        maxPerWallet = 3;
        //set withdraw wallet address
    }

    function setIsPublicMintEnabled(bool _isPublicMintEnabled)
        external
        onlyOwner
    {
        isPublicMintEnabled = _isPublicMintEnabled;
    }

    function setBaseTokenUri(string calldata _baseTokenUri) external onlyOwner {
        baseTokenUri = _baseTokenUri; // url that has the images
    }

    // call to grab the images
    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(_exists(_tokenId), "Token does not exist!");
        return
            string(
                abi.encodePacked(
                    baseTokenUri,
                    Strings.toString(_tokenId),
                    ".json"
                )
            );
    }

    function withdraw() external onlyOwner {
        (bool success, ) = withdrawWallet.call{value: address(this).balance}(
            ""
        ); // withdraw to the address specified
        require(success, "Withdraw failed");
    }

    function mint(uint256 _quantity) public payable {
        require(isPublicMintEnabled, "Minting not enabled");
        require(msg.value == _quantity * mintPrice, "Wrong mint value");
        require(totalSupply + _quantity <= maxSupply, "Sold out");
        require(
            walletMints[msg.sender] + _quantity <= maxPerWallet,
            "exceed max wallet"
        );

        for (uint256 i = 0; i < _quantity; i++) {
            uint256 newTokenId = totalSupply + 1;
            totalSupply++;
            _safeMint(msg.sender, newTokenId);
        }
    }
}
