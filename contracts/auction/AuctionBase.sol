pragma solidity ^0.4.24;

import "../user/UserBase.sol";
import "../common/UtilLib.sol";
import "../common/Msg.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract AuctionBase is Ownable, Msg {
    
    struct Auction {
        
        uint256 id;

        uint256 seller;
        
        Stages stage;
        
        uint64 applicantEndTime;
        
        uint64 biddingEndTime;
        
        uint256 winner;
        
        uint64 createdAt;
        
        uint64 updastedAt;
        
        uint256[] applicants;
        
        uint256[] bidders;
        
        mapping(uint256 => uint128) amount;

        mapping(uint256 => uint128) escrowedERC20;
    }
    
    struct Marriage {
        
        uint256 id;
        
        uint256 seller;
        
        uint256 winner;
    }
    
    /*
     *  Enums
     */
    enum Stages {
        Default,
        Application,
        Bidding,
        WinnerChoosen,
        Cancel
    }
    
    UserBase public userContract;
    
    ERC20 public erc20;
    
    // MarrageCertificationToken public erc721;
    
    uint256[] auctionIds;
    
    // Marriage[] marriages;
    
    uint64 constant MIN_AUCTION_DURATION = 1;
    
    uint8 constant AUCTION_ID_OFFSET = 100;
    
    // uint8 constant MARRIAGE_TOKEN_ID_OFFSET = 100;
    
    mapping (uint256 => Auction) public idToAuction;
    
    mapping (uint256 => uint256) public userIdToAuctionId;
    
    // mapping (uint256 => uint128) internal userIdToEscrowedERC20;
    
    // mapping (uint256 => address) internal userIdToAddress;
    
    // mapping (uint256 => uint256) public userIdToMarriageTokenId;
    
    modifier auctionExist(uint256 _auctionId) {
        require(idToAuction[_auctionId].id == _auctionId, NO_AUCTION);
        _;
    }
    
    modifier auctionExistAndAtStage(uint256 _auctionId, Stages _stage) {
        require(idToAuction[_auctionId].stage == _stage, INVALID_STAGE);
        _;
    }
    
    modifier isSeller(uint256 _auctionId) {
        uint256 userId = userContract.getUserIdIfExist(msg.sender);
        require(idToAuction[_auctionId].seller == userId && userIdToAuctionId[userId] == _auctionId, NOT_SELLER);
        _;
    }
    
    modifier isNotSeller(uint256 _auctionId) {
        uint256 userId = userContract.getUserIdIfExist(msg.sender);
        require(idToAuction[_auctionId].seller != userId, BE_SELLER);
        _;
    }
    
    constructor(address _userConstract, address _erc20) internal {
        userContract = UserBase(_userConstract);
        erc20 = ERC20(_erc20);
        // erc721 = MarrageCertificationToken(_erc721);
    }
    
    function havingAuctionId() external view returns(uint256) {
        uint256 userId = userContract.getUserIdIfExist(msg.sender);
        return userIdToAuctionId[userId] != 0 ? userIdToAuctionId[userId] : 0;
    }
    
    // function havingMarriageTokenId() external view returns(uint256) {
    //     uint256 userId = userContract.getUserIdIfExist(msg.sender);
    //     return userIdToMarriageTokenId[userId] != 0 ? userIdToMarriageTokenId[userId] : 0;
    // }

    
    function isApplied(uint256 _auctionId, uint256 _userId) internal view returns(bool) {
        uint256[] storage applicants = idToAuction[_auctionId].applicants;
        return UtilLib.hasUintArrayUintVal(applicants, _userId) ? true : false;
    }
    
    function isBidder(uint256 _auctionId, uint256 _userId) internal view returns(bool) {
        uint256[] storage bidders = idToAuction[_auctionId].bidders;
        return UtilLib.hasUintArrayUintVal(bidders, _userId) ? true : false;
    }
    
    function hasAuction(uint256 _seller) internal view returns(bool) {
        return userIdToAuctionId[_seller] == 0 ? false : true;
    }
    
    function getApplicants(uint256 _auctionId) 
        external 
        view 
        auctionExist(_auctionId)
        returns(uint256[]) 
    {
        return idToAuction[_auctionId].applicants;
    }
    
    function getApplicantEnd(uint256 _auctionId) 
        external 
        view 
        auctionExist(_auctionId)
        returns(uint64) 
    {
        return idToAuction[_auctionId].applicantEndTime;
    }
    
    function getBiddingEnd(uint256 _auctionId) 
        external 
        view 
        auctionExist(_auctionId)
        returns(uint64) 
    {
        return idToAuction[_auctionId].biddingEndTime;
    }
    
    function getBidders(uint256 _auctionId) 
        external 
        view 
        auctionExist(_auctionId)
        returns(uint256[]) 
    {
        return idToAuction[_auctionId].bidders;
    }
    
    function getBiddedAmount(uint256 _auctionId, uint256 _bidder) 
        external 
        view 
        auctionExist(_auctionId)
        returns(uint128) 
    {
        require(isBidder(_auctionId, _bidder), NOT_BIDDER);
        return idToAuction[_auctionId].amount[_bidder];
    }
    
    function getWinner(uint256 _auctionId)
        external
        view
        auctionExist(_auctionId)
        returns(uint256)
    {
        require(idToAuction[_auctionId].winner != 0, NO_WINNER);
        return idToAuction[_auctionId].winner;
    }

    function getSeller(uint256 _auctionId)
        external
        view
        auctionExist(_auctionId)
        returns(uint256)
    {
        require(idToAuction[_auctionId].seller != 0, NOT_SELLER);
        return idToAuction[_auctionId].seller;
    }
    
    // function getMarriageTokenIfExist(uint256 _tokenId) internal view returns(Marriage) {
    //     require(marriages[ _tokenId - MARRIAGE_TOKEN_ID_OFFSET ].id == _tokenId, INVAL_TOKEN_ID);
    //     return marriages[ _tokenId - MARRIAGE_TOKEN_ID_OFFSET ];
    // }
    
    // function escrowERC20(address _from, uint128 _amount, uint256 _userId) internal {
    //     userIdToEscrowedERC20[_userId] += _amount;
    //     // userIdToAddress[_userId] = _from;
    //     erc20.transferFrom(_from, address(this), _amount);
    // }
    
    
    // function mintERC721(address _to, uint256 _tokenId) internal {
    //     uint256 userId = userContract.getUserIdIfExist(_to);
    //     userIdToMarriageTokenId[userId] = _tokenId;
    //     erc721.mint(_to, _tokenId);
    // }

}
