// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Easy_NFT is ERC721 {
    // Global Variables
    uint public mintFee; // cost per item minted, optional
    uint public itemId; // NFT id's for keeping track of each item
    address public contractOwner; // this is the contract deployer, 100% authorization
    address payable public feeAccount; // this can be == contract owner || new contract

    

}