pragma solidity ^0.4.24;

import "../user/UserBase.sol";
import "../common/UtilLib.sol";
import "../common/Msg.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract AuctionBase is Ownable, Msg {
    
    struct Auction {
        // Auction id assinged when creation
        uint256 id;
        // User id of seller
        uint256 seller;
        // Current auction stage
        Stages stage;
        // End time of application
        uint64 applicantEndTime;
        // End time of bidding
        uint64 biddingEndTime;
        // User id of winner
        uint256 winner;
        // Time created
        uint64 createdAt;
        // Time updated
        uint64 updastedAt;
        // Applications user id
        uint256[] applicants;
        // Bidders use id
        uint256[] bidders;
        // Bidding amount map to user id
        mapping(uint256 => uint128) amount;
        // Current remaining escrowd erc20 token map to user id
        mapping(uint256 => uint128) escrowedERC20;
    }

    /**
     * Auction each stage
     */
    enum Stages {
        Default,         // Skip this stage when auction was successfuly created
        Application,     // First stage of auction
        Bidding,         // Start bidding, after selected bidders.
        WinnerChoosen,   // The last stage of auction. Winner is choosen.
        Cancel           // Seller can cannel auction only at application stage.
    }
    
    UserBase public userContract;
    
    ERC20 public erc20;
    
    uint256[] auctionIds;
    
    uint64 constant MIN_AUCTION_DURATION = 1;
    
    uint8 constant AUCTION_ID_OFFSET = 100;
    
    mapping (uint256 => Auction) public idToAuction;
    
    mapping (uint256 => uint256) public userIdToAuctionId;
    
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
    
    /**
     * @param _userConstract UserAuction contract address
     * @param _erc20 MRAToken address
     */
    constructor(address _userConstract, address _erc20) internal {
        userContract = UserBase(_userConstract);
        erc20 = ERC20(_erc20);
    }
    
    /**
     * @dev Return msg sender having auctuion id
     * @dev Reverts if user don't exist
     * @return Msg sender having auctuion id. If use don't have auction id, return '0'
     */
    function havingAuctionId() external view returns(uint256) {
        uint256 userId = userContract.getUserIdIfExist(msg.sender);
        return userIdToAuctionId[userId] != 0 ? userIdToAuctionId[userId] : 0;
    }
    
    /**
     * @dev Check if user is applied
     * @param _auctionId auction id
     * @param _userId user id
     * @return True, if user is applied
     */
    function isApplied(uint256 _auctionId, uint256 _userId) internal view returns(bool) {
        uint256[] storage applicants = idToAuction[_auctionId].applicants;
        return UtilLib.hasUintArrayUintVal(applicants, _userId) ? true : false;
    }
    
    /**
     * @dev Check if user is bidder
     * @param _auctionId auction id
     * @param _userId user id
     * @return True, if user is bidder
     */
    function isBidder(uint256 _auctionId, uint256 _userId) internal view returns(bool) {
        uint256[] storage bidders = idToAuction[_auctionId].bidders;
        return UtilLib.hasUintArrayUintVal(bidders, _userId) ? true : false;
    }
    
    /**
     * @dev Check if user have auction
     * @param _seller user id
     * @return True, if user have auction
     */
    function hasAuction(uint256 _seller) internal view returns(bool) {
        return userIdToAuctionId[_seller] == 0 ? false : true;
    }
    
    /**
     * @dev Get applications
     * @param _auctionId auction id
     * @return applications
     */
    function getApplicants(uint256 _auctionId) 
        external 
        view 
        auctionExist(_auctionId)
        returns(uint256[]) 
    {
        return idToAuction[_auctionId].applicants;
    }
    
    /**
     * @dev Get application end time
     * @param _auctionId auction id
     * @return Application end time
     */
    function getApplicantEnd(uint256 _auctionId) 
        external 
        view 
        auctionExist(_auctionId)
        returns(uint64) 
    {
        return idToAuction[_auctionId].applicantEndTime;
    }
    
    /**
     * @dev Get bidding end time
     * @param _auctionId auction id
     * @return Bidding end time
     */
    function getBiddingEnd(uint256 _auctionId) 
        external 
        view 
        auctionExist(_auctionId)
        returns(uint64) 
    {
        return idToAuction[_auctionId].biddingEndTime;
    }
    
    /**
     * @dev Get bidders
     * @param _auctionId auction id
     * @return bidders
     */
    function getBidders(uint256 _auctionId) 
        external 
        view 
        auctionExist(_auctionId)
        returns(uint256[]) 
    {
        return idToAuction[_auctionId].bidders;
    }
    
    /**
     * @dev Get bid amount
     * @param _auctionId auction id
     * @param _bidder bidder id
     * @return bid amount
     */
    function getBiddedAmount(uint256 _auctionId, uint256 _bidder) 
        external 
        view 
        auctionExist(_auctionId)
        returns(uint128) 
    {
        require(isBidder(_auctionId, _bidder), NOT_BIDDER);
        return idToAuction[_auctionId].amount[_bidder];
    }
    
    /**
     * @dev Get winner
     * @dev Reverts if winner don't exist
     * @param _auctionId auction id
     * @return winner
     */
    function getWinner(uint256 _auctionId)
        external
        view
        auctionExist(_auctionId)
        returns(uint256)
    {
        require(idToAuction[_auctionId].winner != 0, NO_WINNER);
        return idToAuction[_auctionId].winner;
    }

    /**
     * @dev Get seller
     * @dev Reverts if seller don't exist
     * @param _auctionId auction id
     * @return seller
     */
    function getSeller(uint256 _auctionId)
        external
        view
        auctionExist(_auctionId)
        returns(uint256)
    {
        require(idToAuction[_auctionId].seller != 0, NOT_SELLER);
        return idToAuction[_auctionId].seller;
    }

}
