pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";

contract MarrageCertificationToken is ERC721Token {
    
    string private constant NAME = "MarrageCertification";
    string private constant SYMBOL = "MC";
    
    constructor() public ERC721Token(NAME, SYMBOL) {}
    
    /**
     * @dev Mint a new token
     * @dev Reverts if the given token ID already exists
     * @param _to address the beneficiary that will own the minted token
     * @param _tokenId uint256 ID of the token to be minted by the msg.sender
     */
    function mint(address _to, uint256 _tokenId) public {
        super._mint(_to, _tokenId);
    }

    /**
     * @dev Burn a specific token
     * @dev Reverts if the token does not exist
     * @param _tokenId uint256 ID of the token being burned by the msg.sender
     */
    function burn(uint256 _tokenId) public {
        super._burn(ownerOf(_tokenId), _tokenId);
    }
}

