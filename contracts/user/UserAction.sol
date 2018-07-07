pragma solidity ^0.4.24;

import "./UserBase.sol";
import "openzeppelin-solidity/contracts/lifecycle/Pausable.sol";

contract UserAction is UserBase, Pausable {
    
    event UserRegistered(address user, string name, string country, string gender, uint64 birthday);
    
    event UserUpdated(address user, string name, string country, string gender, uint64 birthday);
    
    event UserAddressChanged(address oldAddress, address newAddress);
    
    event UserResigned(address user, uint64 time);
    
    // constructor() public { } 
    
    function register(
        string _name, 
        uint8 _country, 
        uint8 _genger, 
        uint64 _birthday
    ) 
        external 
        whenNotPaused 
        returns(uint) 
    {
        require(!isRegisted(msg.sender), ALREADY_REGISTERED);
        
        validateUserInfo(_name, _country, _genger, _birthday);
        
        uint256 newUserId = users.length + USER_ID_OFFSET;
        
        User memory user = User({
            id: newUserId,
            name: _name,
            country: uint8(_country),
            gender: uint8(_genger),
            birthday: uint64(_birthday),
            isActive: true,
            createdAt: uint64(now),
            updatedAt: uint64(now)
        });
        
        users.push(user);
        
        addressToUserId[msg.sender] = newUserId;
        
        assert(getUserIfExist(msg.sender).createdAt == uint64(now));
        
        emit UserRegistered(msg.sender, _name, countries[_country], genders[_genger], _birthday);
        
        return newUserId;
    }
    
    function update(
        string _name, 
        uint8 _country, 
        uint8 _genger, 
        uint64 _birthday
    ) 
        external 
        whenNotPaused 
    {
        validateUserInfo(_name, _country, _genger, _birthday);
        
        User memory user = getUserIfExist(msg.sender);
        
        user.name = _name;
        user.country = _country;
        user.gender = _genger;
        user.birthday = _birthday;
        user.updatedAt = uint64(now);
        
        users[addressToUserId[msg.sender] - USER_ID_OFFSET] = user;
        
        assert(getUserIfExist(msg.sender).updatedAt == uint64(now));
        
        emit UserUpdated(msg.sender, _name, countries[_country], genders[_genger], _birthday);
    }
    
    function changeUserAddress(address _new) external whenNotPaused {
        
        require(_new != address(0), ADDRESS_IS_0);
        
        uint256 index = addressToUserId[msg.sender];
        
        addressToUserId[_new] = index;
        
        delete addressToUserId[msg.sender];
        
        assert(addressToUserId[msg.sender] == 0);
        
        emit UserAddressChanged(msg.sender, _new);
    }
    
    function resign() external whenNotPaused {
        
        User memory user = getUserIfExist(msg.sender);
        
        user.isActive = false;
        user.updatedAt = uint64(now);
        
        users[addressToUserId[msg.sender] - USER_ID_OFFSET] = user;
        
        assert(!getUserIfNotActive(msg.sender).isActive);
        
        emit UserResigned(msg.sender, uint64(now));
    }
    
    function validateUserInfo(
        string _name, 
        uint8 _country, 
        uint8 _genger, 
        uint64 _birthday
    ) 
        internal 
        pure 
    {
        require(bytes(_name).length != 0, INVALID_NAME);
        require(_country != uint8(0) && _country <= uint8(3), INVAL_COUNTRY);
        require(_genger == uint8(1) || _genger == uint8(2), INVAL_GENDER);
        require(_birthday != uint64(0), INVAL_BIRTHDAY);
    }
    
    /*
     Kill this smart contract.
    */
    function kill () onlyOwner whenPaused public {
        selfdestruct (owner);
    }
    
}