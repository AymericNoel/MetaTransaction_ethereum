// SPDX-License-Identifier: no-license
pragma solidity >=0.4.22 <0.8.0;

import "./myERC721.sol";

contract MyMinter{
    
    mapping(address => bool) public whitelist;
    myERC721 _myERC721;

    constructor(address ERC721address)public{
        _myERC721 = myERC721(ERC721address);
    }

    
    function signerIsWhitelisted(bytes32 _hash, bytes memory _signature) internal view returns (bool){

        bytes32 r;
        bytes32 s;
        uint8 v;
        // Check the signature length
        if (_signature.length != 65) {
        return false;
        }
        // Divide the signature in r, s and v variables
        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solium-disable-next-line security/no-inline-assembly
        assembly {
        r := mload(add(_signature, 32))
        s := mload(add(_signature, 64))
        v := byte(0, mload(add(_signature, 96)))
        }
        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
        v += 27;
        }
        // If the version is correct return the signer address
        if (v != 27 && v != 28) {
        return false;
        } else {
        // solium-disable-next-line arg-overflow
        return whitelist[ecrecover(keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash)
        ), v, r, s)];
        }
    }

    // function claimAToken(bytes memory _signature, uint256 tokenNumber) public
    // returns (bool)
    // {

    //     // Finding next token id
    //     uint nextTokenToMint = tokenNumber;

    //     // Creating a hash of the concatenation of the ERC721 address and the next token to mint
    //     bytes32 _hash = keccak256(abi.encode(ERC721address, nextTokenToMint));

    //     // Checking that the signer of the mint order is authorized
    //     require(signerIsWhitelisted(_hash, _signature), "Claim: signer not whitelisted or signature invalid");
            
    //     // Checking that the authorized minter is not the claimer
    //     address tokenMintedBy = extractAddress(_hash , _signature);
    //     require(tokenMintedBy != msg.sender, "Minter and sender must be different");

    //     _myERC721.mint(msg.sender,tokenNumber);
    // }
}