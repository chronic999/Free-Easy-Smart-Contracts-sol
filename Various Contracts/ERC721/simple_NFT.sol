// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

/*
||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\//////////////////////////////////////////
||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

 NFT Factory Contract Developed by

    ░█████╗░██████╗░██╗░░░██╗██████╗░████████╗░█████╗░███╗░░██╗██╗░█████╗░
    ██╔══██╗██╔══██╗╚██╗░██╔╝██╔══██╗╚══██╔══╝██╔══██╗████╗░██║██║██╔══██╗
    ██║░░╚═╝██████╔╝░╚████╔╝░██████╔╝░░░██║░░░██║░░██║██╔██╗██║██║██║░░╚═╝
    ██║░░██╗██╔══██╗░░╚██╔╝░░██╔═══╝░░░░██║░░░██║░░██║██║╚████║██║██║░░██╗
    ╚█████╔╝██║░░██║░░░██║░░░██║░░░░░░░░██║░░░╚█████╔╝██║░╚███║██║╚█████╔╝
    ░╚════╝░╚═╝░░╚═╝░░░╚═╝░░░╚═╝░░░░░░░░╚═╝░░░░╚════╝░╚═╝░░╚══╝╚═╝░╚════╝░

    ░█████╗░██╗░░██╗██████╗░░█████╗░███╗░░██╗██╗░█████╗░
    ██╔══██╗██║░░██║██╔══██╗██╔══██╗████╗░██║██║██╔══██╗
    ██║░░╚═╝███████║██████╔╝██║░░██║██╔██╗██║██║██║░░╚═╝
    ██║░░██╗██╔══██║██╔══██╗██║░░██║██║╚████║██║██║░░██╗
    ╚█████╔╝██║░░██║██║░░██║╚█████╔╝██║░╚███║██║╚█████╔╝


This contract is designed to be used as a simple nft factory contract,
and may be used by anyone for similar purposes. Cryptonic chronic takes absolutely no responisibility
for anyone who uses this contract for malicious purposes, or any losses that may occur,
please do not copy and paste any contracts you do not fully understand as it could lead
to losses for you and your project. it is always best to assume all contracts are unsafe until fully
reviewing the code and testing before deployment yourself. no funds are stored on this contract...
please enjoy, happy coding
**PLEASE DO NOT REMOVE THIS COMMENT, JUST COMMENT BELOW, THANKS**

||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\//////////////////////////////////////////
||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
*/

contract Easy_NFT is ERC721, IERC721Receiver, ERC721URIStorage {
    // Global Variables
    bool public pause = true; // for pausing contract to update or maintain certain func's
    bool private locked; // for locking contract during attempted attacks
    uint public mintFee; // cost per item minted, optional
    uint private nftCounter; // keeps track of nft count from this contract
    uint public mintLimit = 1; // set max mint amount, erc721 is a true non-fungible asset
    address public contractOwner; // this is the contract deployer, 100% authorization
    address payable public feeAccount; // this can be == contract owner || new contract
    address public marketAddress; // set this to the marketplace you wish to interact with

    // contract mappings
    mapping(uint => address) private nftArtist; // sets original minting address
    mapping(uint => uint) private mintDate; // to verify the actual mint date 
    mapping(uint256 => string) private _tokenURIs;

    // contract constructor function, only runs once on deployment,
    // but variables set within it can be updated later if needed.
    constructor(uint _feeAmount, address _feeWallet, address _marketplace) ERC721("Easy NFT", "EZT") {
        contractOwner = payable(msg.sender); // sets whoever deploys this contract to the owner adrs
        mintFee = _feeAmount * 10**18 wei; // this sets price to whatever amount entered, converted to wei
        feeAccount = payable(_feeWallet); // this can be any payable wallet or contract adrs
        marketAddress = _marketplace; // this sets the marketplace variable on deployment
    }

    modifier onlyOwner() {
        require(msg.sender == contractOwner, "not owner!");
        _;
    }

    modifier Paused() {
        require(pause, "contract must be paused");
        _;
    }

    modifier unPaused() {
        require(!pause, "contract must be unpaused");
        _;
        // this modifier requires contract to be unpaused,
        // if paused tx will fail
    }

    function setPause() public onlyOwner {
        bool _state = pause;
        if (!pause) {
            _state = true;
        } else {
            _state = false;
        }
        pause = _state;

        // this is a switch function, 
        // will switch to false if true and vice versa
    }

    function mintNFT() public payable unPaused {
        require(msg.value >= mintFee, "not enough to mint");
        nftCounter++;
        uint newItemId = nftCounter;
        nftArtist[newItemId] = msg.sender;
        mintDate[newItemId] = block.timestamp;
        _safeMint(msg.sender, newItemId);
        setApprovalForAll(marketAddress, true);
    }

    function setNewMarketplace(address _newMarketplace) public onlyOwner Paused {
        require(_newMarketplace != marketAddress, "adrs already set");
        marketAddress = _newMarketplace;
    }
    
    function _burn(uint256 _itemId) internal virtual override(ERC721, ERC721URIStorage) {
        super._burn(_itemId);
    }

    function tokenURI(uint256 tokenId) public view virtual override(ERC721, ERC721URIStorage) returns (string memory) {
        _requireMinted(tokenId);
        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        return super.tokenURI(tokenId);
    }

    function onERC721Received(address, address, uint256, bytes calldata) public pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }

}