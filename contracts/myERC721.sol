// SPDX-License-Identifier: no-license
pragma solidity >=0.4.22 <0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract myERC721 is ERC721{
    
    uint256 tokenId=0;
    constructor(string memory name, string memory symbol) ERC721(name,symbol) public{
    }

    function mint()public {
        _mint(msg.sender, tokenId);
        tokenId++;
    }

}