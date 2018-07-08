pragma solidity ^0.4.24;

import "./AuctionBase.sol";
import "../user/UserBase.sol";
import "../common/Msg.sol";
import "../token/MarrageCertificationToken.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/lifecycle/Pausable.sol";

contract IssueMCT is Ownable, Pausable, Msg {

    struct Marriage {
        // Token id assigned when issue
        uint256 id;
        // Auction seller id
        uint256 seller;
        // Auction winnr id
        uint256 winner;
    }


    Marriage[] marriages;

    UserBase public userContract;

    MarrageCertificationToken public erc721;

    AuctionBase public auction;

    uint8 constant MARRIAGE_TOKEN_ID_OFFSET = 100;

    mapping (uint256 => uint256) public userIdToMarriageTokenId;

    event AuctionERC721TokenIssued(uint256 auctionId, uint256 tokenId);

    /**
     * @param _user UserAuction contract address
     * @param _erc721 MRAToken address
     * @param _auction AuctionAction contract address
     */
    constructor(address _user, address _erc721, address _auction) public {
        userContract = UserBase(_user);
        erc721 = MarrageCertificationToken(_erc721);
        auction = AuctionBase(_auction);
    }

    /**
     * @dev Get token
     * @dev Reverts if token don't eist
     * @param _tokenId token id
     */
    function getMarriageTokenIfExist(uint256 _tokenId) internal view returns(Marriage) {
        require(marriages[ _tokenId - MARRIAGE_TOKEN_ID_OFFSET ].id == _tokenId, INVAL_TOKEN_ID);
        return marriages[ _tokenId - MARRIAGE_TOKEN_ID_OFFSET ];
    }

    /**
     * @dev Issue token
     * @dev Reverts if auction winner have not yet choosen
     * @dev Reverts if user is not auction seller
     * @param _auctionId auction id
     * @return assinged token id
     */
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

    /**
     * @dev Mint token
     * @param _to reciver address
     * @param _tokenId token id
     * @param _userId send user id
     */
    function mintERC721(address _to, uint256 _tokenId, uint256 _userId) internal {
        userIdToMarriageTokenId[_userId] = _tokenId;
        erc721.mint(_to, _tokenId);
    }
    
    /**
     * @dev Kill this smart contract.
     */
    function kill () onlyOwner whenPaused public {
        selfdestruct (owner);
    }

}
