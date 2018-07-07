pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/crowdsale/Crowdsale.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract MRACrowdsale is Crowdsale {
    
     uint public rate = 1;
    
    constructor(ERC20 _token) 
        public Crowdsale(rate, msg.sender, ERC20(_token)) {}
        
    function () external payable {
        super.buyTokens(msg.sender);
    }
    
    function buyTokens(address _beneficiary) public payable {
        super.buyTokens(_beneficiary);
    }
    
}