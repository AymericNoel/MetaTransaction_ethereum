// SPDX-License-Identifier: no-license
pragma solidity >=0.4.22 <0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract myERC721 is ERC721{
    
    uint256 newTokenId=0;
    mapping(address => bool) public whitelist;
    address deployer;
    
    constructor() ERC721("myERC721","ME72") public{
        whitelist[msg.sender]= true;
        deployer= msg.sender;
    }

    function mint(address to, uint256 tokenId) public {
        require(msg.sender == address(0), "must be the contract owner");
        _mint(to, tokenId);
        newTokenId++;
    }

    modifier OnlyAdmin(){
        require(msg.sender==deployer,"Must be the deployer of the contract");
        _;
    }

    function AddInWhitelist(address _toWhitelist) OnlyAdmin() public {
        whitelist[_toWhitelist] = true;
    }
}