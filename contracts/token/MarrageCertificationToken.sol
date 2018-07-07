pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";

contract MarrageCertificationToken is ERC721Token {
    
    string private constant NAME = "MarrageCertification";
    string private constant SYMBOL = "MC";
    
    constructor() public ERC721Token(NAME, SYMBOL) {}
    
    function mint(address _to, uint256 _tokenId) public {
        super._mint(_to, _tokenId);
    }

    function burn(uint256 _tokenId) public {
        super._burn(ownerOf(_tokenId), _tokenId);
    }

    function setTokenURI(uint256 _tokenId, string _uri) public {
        super._setTokenURI(_tokenId, _uri);
    } 
}

