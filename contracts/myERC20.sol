// SPDX-License-Identifier: no-license
pragma solidity >=0.4.22 <0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract myERC20 is ERC20{
    
    constructor() public ERC20("myERC20","ME2"){
        _mint(msg.sender, 12000* 10**18);
    }

}