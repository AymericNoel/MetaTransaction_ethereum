// SPDX-License-Identifier: no-license
pragma solidity >=0.4.22 <0.8.0;

import "./myERC721.sol";

contract MyMinter{
    
    bytes32 public HashToSign= "You must sign this";
    mapping(address => bool) public whitelist;
    myERC721 _myERC721;
    address public ERC721address;
    constructor()public{
        whitelist[msg.sender] = true;
        whitelist[address(0x9d9fFD857c0B1908C961D2FB7E5a4fc5871FFCE1)]=true;
    }

    function addressERC721(address addr) public{
        ERC721address = addr;
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

    function extractAddress(bytes32 _hash, bytes memory _signature) internal view returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;
        // Check the signature length
        if (_signature.length != 65) {
            return address(0);
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
            return address(0);
        } else {
            // solium-disable-next-line arg-overflow
            return ecrecover(keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash)
                ), v, r, s);
        }
    }

    function claimAToken(bytes memory _signature, uint256 tokenNumber) public
    returns (bool)
    {
        _myERC721 = myERC721(ERC721address);

        // Checking that the signer of the mint order is authorized
        require(signerIsWhitelisted(HashToSign, _signature), "Claim: signer not whitelisted or signature invalid");
            
        // Checking that the authorized minter is not the claimer
        address tokenMintedBy = extractAddress(HashToSign , _signature);
        require(tokenMintedBy != msg.sender, "Minter and sender must be different");

        _myERC721.mint(msg.sender,tokenNumber);
    }
}