pragma solidity ^0.4.24;

import "./AuctionBase.sol";
import "../user/UserBase.sol";
import "../common/Msg.sol";
import "../token/MarrageCertificationToken.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/lifecycle/Pausable.sol";

contract IssueMCT is Ownable, Pausable, Msg {

    struct Marriage {
        
        uint256 id;
        
        uint256 seller;
        
        uint256 winner;
    }


    Marriage[] marriages;

    UserBase public userContract;

    MarrageCertificationToken public erc721;

    AuctionBase public auction;

    uint8 constant MARRIAGE_TOKEN_ID_OFFSET = 100;

    mapping (uint256 => uint256) public userIdToMarriageTokenId;

    event AuctionERC721TokenIssued(uint256 auctionId, uint256 tokenId);

    constructor(address _user, address _erc721, address _auction) public {
        userContract = UserBase(_user);
        erc721 = MarrageCertificationToken(_erc721);
        auction = AuctionBase(_auction);
    }

    function getMarriageTokenIfExist(uint256 _tokenId) internal view returns(Marriage) {
        require(marriages[ _tokenId - MARRIAGE_TOKEN_ID_OFFSET ].id == _tokenId, INVAL_TOKEN_ID);
        return marriages[ _tokenId - MARRIAGE_TOKEN_ID_OFFSET ];
    }

    function issueERC721Token(uint256 _auctionId)
        external
        whenNotPaused
        returns(uint256)
    {
        require(auction.getWinner(_auctionId) != 0, INVALID_STAGE);
        uint256 userId = userContract.getUserIdIfExist(msg.sender);
        require(auction.getSeller(_auctionId) == userId, NOT_SELLER);
        
        uint256 newTokenId = marriages.length + MARRIAGE_TOKEN_ID_OFFSET;
        
        Marriage memory mariage = Marriage({
            id: newTokenId,
            seller: auction.getSeller(_auctionId),
            winner: auction.getWinner(_auctionId)
        });
        
        marriages.push(mariage);
        
        mintERC721(msg.sender, newTokenId, userId);
        
        assert(getMarriageTokenIfExist(newTokenId).id == newTokenId);
        
        emit AuctionERC721TokenIssued(_auctionId, newTokenId);
        
        return newTokenId;
    }

    function mintERC721(address _to, uint256 _tokenId, uint256 _userId) internal {
        userIdToMarriageTokenId[_userId] = _tokenId;
        erc721.mint(_to, _tokenId);
    }

    /*
     Kill this smart contract.
    */
    function kill () onlyOwner whenPaused public {
        selfdestruct (owner);
    }

}
