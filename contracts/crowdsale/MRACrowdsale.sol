pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/crowdsale/Crowdsale.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract MRACrowdsale is Crowdsale, Ownable {
    
    uint public rate = 1;
    
    /**
     * @param _token MRAToken address
     */
    constructor(ERC20 _token) 
        public Crowdsale(rate, msg.sender, ERC20(_token)) {}
        
    /**
     * @dev fallback function
     */
    function () external payable {
        super.buyTokens(msg.sender);
    }
    
    /**
     * @dev Token purchase
     * @param _beneficiary Address performing the token purchase
     */
    function buyTokens(address _beneficiary) public payable {
        super.buyTokens(_beneficiary);
    }

    /**
     * @dev Kill this smart contract.
     */
    function kill () onlyOwner public {
        selfdestruct (owner);
    }
    
}