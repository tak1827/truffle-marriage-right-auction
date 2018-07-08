pragma solidity ^0.4.24;

import "./UserBase.sol";
import "openzeppelin-solidity/contracts/lifecycle/Pausable.sol";

contract UserAction is UserBase, Pausable {
    
    event UserRegistered(address user, string name, string country, string gender, uint64 birthday);
    
    event UserUpdated(address user, string name, string country, string gender, uint64 birthday);
    
    event UserAddressChanged(address oldAddress, address newAddress);
    
    event UserResigned(address user, uint64 time);
    
    /**
     * @dev Register user
     * @dev Reverts if the user have already registerd
     * @param _name user name
     * @param _country the number of countries array
     * @param _gender the number of genders array
     * @return Assined user id
     */
    function register(
        string _name, 
        uint8 _country, 
        uint8 _gender, 
        uint64 _birthday
    ) 
        external 
        whenNotPaused 
        returns(uint) 
    {
        require(!isRegisted(msg.sender), ALREADY_REGISTERED);
        
        validateUserInfo(_name, _country, _gender, _birthday);
        
        uint256 newUserId = users.length + USER_ID_OFFSET;
        
        User memory user = User({
            id: newUserId,
            name: _name,
            country: uint8(_country),
            gender: uint8(_gender),
            birthday: uint64(_birthday),
            isActive: true,
            createdAt: uint64(now),
            updatedAt: uint64(now)
        });
        
        users.push(user);
        
        addressToUserId[msg.sender] = newUserId;
        
        assert(getUserIfExist(msg.sender).createdAt == uint64(now));
        
        emit UserRegistered(msg.sender, _name, countries[_country], genders[_gender], _birthday);
        
        return newUserId;
    }
    
    /**
     * @dev Update user info
     * @dev Reverts if the user don't exist
     * @param _name user name
     * @param _country the number of countries array
     * @param _gender the number of genders array
     * @return Assined user id
     */
    function update(
        string _name, 
        uint8 _country, 
        uint8 _gender, 
        uint64 _birthday
    ) 
        external 
        whenNotPaused 
    {
        validateUserInfo(_name, _country, _gender, _birthday);
        
        User memory user = getUserIfExist(msg.sender);
        
        user.name = _name;
        user.country = _country;
        user.gender = _gender;
        user.birthday = _birthday;
        user.updatedAt = uint64(now);
        
        users[addressToUserId[msg.sender] - USER_ID_OFFSET] = user;
        
        assert(getUserIfExist(msg.sender).updatedAt == uint64(now));
        
        emit UserUpdated(msg.sender, _name, countries[_country], genders[_gender], _birthday);
    }
    

    /**
     * @dev Change use raddress
     * @dev Reverts if the user don't exist
     * @param _new New address
     */
    function changeUserAddress(address _new) external whenNotPaused {
        
        require(_new != address(0), ADDRESS_IS_0);
        uint256 index = getUserIdIfExist(msg.sender);
        
        addressToUserId[_new] = index;
        
        delete addressToUserId[msg.sender];
        
        assert(addressToUserId[msg.sender] == 0);
        
        emit UserAddressChanged(msg.sender, _new);
    }
    
    /**
     * @dev Resign user. Don't delete, just set inactive.
     * @dev Reverts if the user don't exist
     */
    function resign() external whenNotPaused {
        
        User memory user = getUserIfExist(msg.sender);
        
        user.isActive = false;
        user.updatedAt = uint64(now);
        
        users[addressToUserId[msg.sender] - USER_ID_OFFSET] = user;
        
        assert(!users[ addressToUserId[msg.sender] - USER_ID_OFFSET ].isActive);
        
        emit UserResigned(msg.sender, uint64(now));
    }
    
    /**
     * @dev Validate user inputed info
     * @param _name user name
     * @param _country the number of countries array
     * @param _gender the number of genders array
     */
    function validateUserInfo(
        string _name, 
        uint8 _country, 
        uint8 _gender, 
        uint64 _birthday
    ) 
        internal 
        pure 
    {
        require(bytes(_name).length != 0, INVALID_NAME);
        require(_country != uint8(0) && _country <= uint8(3), INVAL_COUNTRY);
        require(_gender == uint8(1) || _gender == uint8(2), INVAL_GENDER);
        require(_birthday != uint64(0), INVAL_BIRTHDAY);
    }
    
    /**
     * @dev Kill this smart contract.
     */
    function kill () onlyOwner whenPaused public {
        selfdestruct (owner);
    }
    
}