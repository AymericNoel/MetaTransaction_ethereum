pragma solidity >=0.5.0 <0.8.0;

//use case 1:
//you deploy the bouncer proxy and use it as a standard identity for your own etherless accounts
//  (multiple devices you don't want to store eth on or move private keys to will need to be added as Bouncers)
//you run your own relayer and the rewardToken is 0

//use case 2:
//you deploy the bouncer proxy and use it as a standard identity for your own etherless accounts
//  (multiple devices you don't want to store eth on or move private keys to will need to be added as Bouncers)
//  a community if relayers are incentivized by the rewardToken to pay the gas to run your transactions for you
//SEE: universal logins via @avsa

//use case 3:
//you deploy the bouncer proxy and use it to let third parties submit transactions as a standard identity
//  (multiple developer accounts will need to be added as Bouncers to 'whitelist' them to make meta transactions)
//you run your own relayer and pay for all of their transactions, revoking any bad actors if needed
//SEE: GitCoin (via @owocki) wants to pay for some of the initial transactions of their Developers to lower the barrier to entry

//use case 4:
//you deploy the bouncer proxy and use it to let third parties submit transactions as a standard identity
//  (multiple developer accounts will need to be added as Bouncers to 'whitelist' them to make meta transactions)
//you run your own relayer and pay for all of their transactions, revoking any bad actors if needed

contract BouncerProxy {
  //whitelist the deployer so they can whitelist others
  constructor() public {
     whitelist[msg.sender] = true;
  }
  //to avoid replay
  mapping(address => uint) public nonce;
  // allow for third party metatx account to make transactions through this
  // contract like an identity but make sure the owner has whitelisted the tx
  mapping(address => bool) public whitelist;
  function updateWhitelist(address _account, bool _value) public returns(bool) {
   require(whitelist[msg.sender],"BouncerProxy::updateWhitelist Account Not Whitelisted");
   whitelist[_account] = _value;
   emit UpdateWhitelist(_account,_value);
   return true;
  }
  event UpdateWhitelist(address _account, bool _value);
  // copied from https://github.com/uport-project/uport-identity/blob/develop/contracts/Proxy.sol
//   function () public payable { 
//       emit Received(msg.sender, msg.value); 
//   }
  event Received (address indexed sender, uint value);

  function getHash(address signer, address destination, uint value, bytes memory data, address rewardToken, uint rewardAmount) public view returns(bytes32){
    return keccak256(abi.encodePacked(address(this), signer, destination, value, data, rewardToken, rewardAmount, nonce[signer]));
  }


  // original forward function copied from https://github.com/uport-project/uport-identity/blob/develop/contracts/Proxy.sol
  function forward(bytes memory sig, address signer, address destination, uint value, bytes memory data, address rewardToken, uint rewardAmount) public payable{
      //the hash contains all of the information about the meta transaction to be called
      bytes32 _hash = getHash(signer, destination, value, data, rewardToken, rewardAmount);
      //increment the hash so this tx can't run again
      nonce[signer]++;
      //this makes sure signer signed correctly AND signer is a valid bouncer
      require(signerIsWhitelisted(_hash,sig),"BouncerProxy::forward Signer is not whitelisted");
      //make sure the signer pays in whatever token (or ether) the sender and signer agreed to
      // or skip this if the sender is incentivized in other ways and there is no need for a token
      if(rewardAmount>0){
        //Address 0 mean reward with ETH
        if(rewardToken==address(0)){
          //REWARD ETHER
          (bool success,) = msg.sender.call{value: rewardAmount}("");
          require(success, "transaction failed");
        //   require(msg.sender.call{value: rewardAmount}{gas: 36000},"");
        }else{
          //REWARD TOKEN
          require((StandardToken(rewardToken)).transfer(msg.sender,rewardAmount));
        }
      }
      //execute the transaction with all the given parameters
      require(executeCall(destination, value, data));
      emit Forwarded(sig, signer, destination, value, data, rewardToken, rewardAmount, _hash);
  }


  // when some frontends see that a tx is made from a bouncerproxy, they may want to parse through these events to find out who the signer was etc
  event Forwarded (bytes sig, address signer, address destination, uint value, bytes data,address rewardToken, uint rewardAmount,bytes32 _hash);

  // copied from https://github.com/uport-project/uport-identity/blob/develop/contracts/Proxy.sol
  // which was copied from GnosisSafe
  // https://github.com/gnosis/gnosis-safe-contracts/blob/master/contracts/GnosisSafe.sol
  function executeCall(address to, uint256 value, bytes memory data) internal returns (bool success) {
    assembly {
       success := call(gas(), to, value, add(data, 0x20), mload(data), 0, 0)
    }
  }

  //borrowed from OpenZeppelin's ESDA stuff:
  //https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/cryptography/ECDSA.sol
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
}

contract StandardToken {
  function transfer(address _to,uint256 _value) public returns (bool) { }
}
