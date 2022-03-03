// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import '@openzepplin/contracts/token/ERC721/ERC721.sol';
import '@openzepplin/contracts/access/Ownable.sol';


// Unlike other programming languages where you refactor for improved speed and performance,
// with smart contracts you want to refactor to have your contract contain the LEAST
// amount of variables that are saved to the blockchain. Every single variable you add below is
// another expense on the blockchain. Less is more, but you also can't miss things!
// The more you write to variables, the more transactions you need to pay for.

contract SimpleMint is ERC721, Ownable {
    uint256 public mintPrice = 0.05 ether;
    uint256 public totalSupply;
    uint256 public maxSupply;
    // You don't always want the mint to become live right as you deploy.
    // Its better practice to have this switch, and then flip it to true when you are 100% ready to launch.
    // Also, Solidity bools default to false if they are not given a value. Thus, our value below is
    // equal to false by default. 
    bool public isMintEnabled;

    // Keep track of the number of mints each wallet has done.
    // We don't want 1 wallet to mint them all etc.
    mapping(address => uint256) public mintedWallets;

    constructor() payable ERC721('Simple Mint', 'MINT') {
        maxSupply = 2;
    }

    // This function is only accessible by the owner. Comes from 'Ownable' above.
    function toggleIsMintEnabled() external onlyOwner {
        isMintEnabled = !isMintEnabled;
    }

    function setMaxSupply(uint256 _maxSupply) external onlyOwner {
        maxSupply = _maxSupply;
    }

    function mint() external payable {
        require(isMintEnabled, 'minting not enabled.');
        // This is a crucial line. If you dont set this, one user could mint all of the nfts which ruins your launch immediately.
        // Launuches have been ruined because they were missing a line of code like this.
        require(mintedWallets[msg.sender] < 1, 'exceeds max minted per wallet');
        require(msg.value == mintPrice, 'user did not enter the appropriate mint price');
        require(maxSupply > totalSupply, 'Sold out');

        mintedWallets[msg.sender]++;
        totalSupply++;
        uint256 tokenId = totalSupply;
        // this one line below handles all minting functionality for you safely! always use this when minting.
        // it is well tested and the accepted standard. dont introduce chances for errors by writing it yourself.
        // Still important to learn how it functions though.
        _safeMint(msg.sender, tokenId);
    }
}