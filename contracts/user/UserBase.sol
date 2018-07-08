pragma solidity ^0.4.24;

import "../common/Msg.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract UserBase is Ownable, Msg {
    
    struct User {
        // User id assignd when creation
        uint256 id;
        // Registerd user name
        string name;
        // Living country
        uint8 country;
        // Male or Femail only
        uint8 gender;
        // mm/dd/yyyy format
        uint64 birthday;
        // User activation flg
        bool isActive;
        // Time created
        uint64 createdAt;
        // Time updated
        uint64 updatedAt;
    }

    // TODO: Need write all existing countries
    string[4] countries = ["Default", "Afghanistan", "Argentina", "Australia"];
    
    string[3] genders = ["Default" ,"Male", "Female"];
    
    User[] users;
    
    uint8 constant USER_ID_OFFSET = 100;
    
    mapping (address => uint256) public addressToUserId;
    
    /**
     * @dev Get user
     * @dev Reverts if the user don't exist or inactive
     * @param _user address of user
     */
    function getUserIfExist(address _user) internal view returns(User) {
        require(_user != address(0), ADDRESS_IS_0);
        require(addressToUserId[_user] != 0, NO_USER);
        User memory user = users[ addressToUserId[_user] - USER_ID_OFFSET ];
        require(user.isActive, USER_NOT_ACTIVE);
        return user;
    }

    /**
     * @dev Get user id
     * @dev Reverts if the user don't exist or inactive
     * @param _user address of user
     */
    function getUserIdIfExist(address _user) public view returns(uint256) {
        return getUserIfExist(_user).id;
    }
    
    /**
     * @dev Get user name
     * @dev Reverts if the user don't exist or inactive
     * @param _user address of user
     */
    function getUserNameIfExist(address _user) external view returns(string) {
        return getUserIfExist(_user).name;
    }
    
    /**
     * @dev Check if user have already registered
     * @param _user address of user
     * @return Return 'true' if user have already registered
     */
    function isRegisted(address _user) internal view returns(bool) {
        require(_user != address(0), ADDRESS_IS_0);
        return addressToUserId[_user] == 0 ? false : true;
    }
    
}