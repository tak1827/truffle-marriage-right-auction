pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/PausableToken.sol";

contract MRAToken is PausableToken {
    
    string public constant NAME = "MarrageRightAuction";
    string public constant SYMBOL = "MRA";
    uint public constant DECIMALS = 18;
    uint public constant INITIAL_SUPPLY = 10000 * (10 ** DECIMALS);
    
    constructor() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
    }
    
}
