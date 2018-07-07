pragma solidity ^0.4.24;

import "../common/Msg.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract UserBase is Ownable, Msg {
    
    struct User {
        
        uint256 id;
        
        string name;
        
        uint8 country;
        
        uint8 gender;
        
        uint64 birthday;
        
        bool isActive;
        
        uint64 createdAt;
        
        uint64 updatedAt;
    }
    
    string[4] countries = ["Default", "Afghanistan", "Argentina", "Australia"];
    
    string[3] genders = ["Default" ,"Male", "Female"];
    
    User[] users;
    
    uint8 constant USER_ID_OFFSET = 100;
    
    mapping (address => uint256) public addressToUserId;
    
    event UserRegistered(address user, string name, string country, string gender, uint64 birthday);
    
    event UserUpdated(address user, string name, string country, string gender, uint64 birthday);
    
    event UserAddressChanged(address oldAddress, address newAddress);
    
    event UserResigned(address user, uint64 time);
    
    // constructor() public { } 
    
    function getUserIfExist(address _user) internal view returns(User) {
        require(_user != address(0), ADDRESS_IS_0);
        require(addressToUserId[_user] != 0, NO_USER);
        User memory user = users[ addressToUserId[_user] - USER_ID_OFFSET ];
        require(user.isActive, USER_NOT_ACTIVE);
        return user;
    }

    function getUserIfNotActive(address _user) internal view returns(User) {
        require(_user != address(0), ADDRESS_IS_0);
        require(addressToUserId[_user] != 0, NO_USER);
        User memory user = users[ addressToUserId[_user] - USER_ID_OFFSET ];
        require(!user.isActive, USER_IS_ACTIVE);
        return user;
    }
    
    function getUserIdIfExist(address _user) external view returns(uint256) {
        return getUserIfExist(_user).id;
    }
    
    function getUserNameIfExist(address _user) external view returns(string) {
        return getUserIfExist(_user).name;
    }
    
    function getUserUpdatedAtIfExist(address _user) external view returns(uint64) {
        return getUserIfExist(_user).updatedAt;
    }
    
    function isRegisted(address _user) internal view returns(bool) {
        require(_user != address(0), ADDRESS_IS_0);
        return addressToUserId[_user] == 0 ? false : true;
    }
    
}