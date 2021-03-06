pragma solidity ^0.4.24;

import "./AuctionBase.sol";
import "openzeppelin-solidity/contracts/lifecycle/Pausable.sol";

contract AuctionAction is AuctionBase, Pausable {
    
    event AuctionCreated(uint256 userId, uint64 applicantEndTime, uint256 auctionId);
    
    event AuctionApplied(uint256 auctionId, uint256 userId);
    
    event AuctionBidderSelected(uint256 auctionId, uint256 applicantId);
    
    event AuctionApplicationEnd(uint256 auctionId, uint64 applicantEndTime);
    
    event AuctionCanceled(uint256 auctionId);
    
    event AuctionBiddingStarted(uint256 auctionId, uint64 biddingEndTime);
    
    event AuctionBidded(uint256 auctionId, uint256 bidder, uint128 amount, uint128 totalAmount);
    
    event AuctionBiddingEnd(uint256 auctionId, uint64 biddingEndTime);
    
    event AuctionWinnerChoosen(uint256 auctionId, uint256 winner);
    
    constructor(address _userConstract, address _erc20) 
        public AuctionBase(_userConstract, _erc20) {}
    
    /**
     * @dev Create auction
     * @dev Reverts if duration is nunder 'MIN_AUCTION_DURATION'
     * @dev Reverts if user don't exist or already haveing auction
     * @param _duration application term
     * @return assignd auction id
     */
    function createAuction(uint64 _duration) external whenNotPaused returns(uint256) {
        
        require(_duration >= MIN_AUCTION_DURATION, TOO_SMALL_DURATION);
        uint256 userId = userContract.getUserIdIfExist(msg.sender);
        require(!hasAuction(userId), ANOTHER_AUCTION_HAVING);
        
        uint256 newAuctionId = auctionIds.length + AUCTION_ID_OFFSET;
        uint64 applicantEndTime = uint64(_duration) + uint64(now);
        
        idToAuction[newAuctionId].id = newAuctionId;
        idToAuction[newAuctionId].seller = userId;
        idToAuction[newAuctionId].stage = Stages.Application;
        idToAuction[newAuctionId].applicantEndTime = applicantEndTime;
        idToAuction[newAuctionId].createdAt = uint64(now);
        idToAuction[newAuctionId].updastedAt = uint64(now);
        
        userIdToAuctionId[userId] = newAuctionId;
        
        auctionIds.push(newAuctionId);
        
        assert(idToAuction[newAuctionId].createdAt == uint64(now));
        
        emit AuctionCreated(userId, applicantEndTime, newAuctionId);
        
        return newAuctionId;
    }
    

    /**
     * @dev Apply to auction
     * @dev Reverts if auction is not application stage or out of application term
     * @dev Reverts if user or auction don't exist
     * @param _auctionId application id
     */
    function apply(uint256 _auctionId) 
        external 
        whenNotPaused
        auctionExistAndAtStage(_auctionId, Stages.Application)
        isNotSeller(_auctionId)
    {
        require(idToAuction[_auctionId].applicantEndTime > uint64(now), APPLICATION_END);
        uint256 userId = userContract.getUserIdIfExist(msg.sender);
        require(!isApplied(_auctionId, userId), ALREADY_APPLIED);
        
        idToAuction[_auctionId].applicants.push(userId);
        
        assert(isApplied(_auctionId, userId));
        
        emit AuctionApplied(_auctionId, userId);
    }
    
    /**
     * @dev Apply to auction
     * @dev Reverts if auction is not application stage
     * @dev Reverts if applicant don't exist or already selected
     * @param _auctionId application id
     * @param _applicantId applicant id
     */
    function selectBidders(uint256 _auctionId, uint256 _applicantId) 
        external 
        whenNotPaused
        auctionExistAndAtStage(_auctionId, Stages.Application)
        isSeller(_auctionId)
    {
        require(isApplied(_auctionId, _applicantId), INVAL_APPLICATION_ID);
        require(!isBidder(_auctionId, _applicantId), ALREADY_SELECTED);
        
        idToAuction[_auctionId].bidders.push(_applicantId);
        
        assert(isBidder(_auctionId, _applicantId));
        
        emit AuctionBidderSelected(_auctionId, _applicantId);
    }
    
    /**
     * @dev Extend application term
     * @dev If within application term, simply extend. If out of application term, restart application term
     * @dev Reverts if auction is not application stage
     * @param _auctionId application id
     * @param _duration extension time
     */
    function extendApplicationEnd(uint256 _auctionId, uint64 _duration)
        external
        whenNotPaused
        auctionExistAndAtStage(_auctionId, Stages.Application)
        isSeller(_auctionId)
    {
        require(_duration != 0, DURATION_IS_0);
        
        uint64 applicantEndTime = idToAuction[_auctionId].applicantEndTime;
        
        if (applicantEndTime > uint64(now)) {
            applicantEndTime += _duration;
        } else {
            applicantEndTime = uint64(now) + _duration;
        }
        
        idToAuction[_auctionId].applicantEndTime = applicantEndTime;
        
        assert(idToAuction[_auctionId].applicantEndTime == applicantEndTime);
        
        emit AuctionApplicationEnd(_auctionId, applicantEndTime);
    }
        
    /**
     * @dev Cancel auction. Only possible within application term.
     * @dev Reverts if auction is not application stage
     * @param _auctionId application id
     */
    function cancelAuction(uint256 _auctionId)
        external
        whenNotPaused
        auctionExistAndAtStage(_auctionId, Stages.Application)
        isSeller(_auctionId)
    {
        uint256 userId = userContract.getUserIdIfExist(msg.sender);
        
        delete userIdToAuctionId[userId];
        idToAuction[_auctionId].stage = Stages.Cancel;
        
        assert(userIdToAuctionId[userId] == 0);
        assert(idToAuction[_auctionId].stage == Stages.Cancel);
        
        emit AuctionCanceled(_auctionId);
    }
    
    /**
     * @dev Start bidding stage
     * @dev Reverts if auction is not application stage or within application term.
     * @dev Reverts if bidders don't exist
     * @dev Reverts if duration is under 'MIN_AUCTION_DURATION'
     * @param _auctionId application id
     * @param _duration bidding term
     */
    function biddingStart(uint256 _auctionId, uint64 _duration) 
        external
        whenNotPaused
        auctionExistAndAtStage(_auctionId, Stages.Application)
        isSeller(_auctionId)
    {
        require(idToAuction[_auctionId].applicantEndTime < uint64(now), NOT_APPLICATION_END);
        require(idToAuction[_auctionId].bidders.length != 0, BIDDER_IS_EMPTY);
        require(_duration >= MIN_AUCTION_DURATION, TOO_SMALL_DURATION);
        
        uint64 biddingEndTime = uint64(_duration) + uint64(now);
        
        idToAuction[_auctionId].biddingEndTime = biddingEndTime;
        idToAuction[_auctionId].stage = Stages.Bidding;
        
        assert(idToAuction[_auctionId].stage == Stages.Bidding);
        
        emit AuctionBiddingStarted(_auctionId, biddingEndTime);
    }
        
    /**
     * @dev Bid to auction
     * @dev If bidder have still be bidded, just add amount.
     * @dev Reverts if auction is not bidding stage or out of bidding term
     * @dev Reverts if user is not bidder
     * @dev Reverts if user don't hold more than bidded token
     * @param _auctionId application id
     * @param _amount bidded amount
     */
    function bid(uint256 _auctionId, uint128 _amount) 
        external 
        whenNotPaused
        auctionExistAndAtStage(_auctionId, Stages.Bidding)
        isNotSeller(_auctionId)
    {
        require(idToAuction[_auctionId].biddingEndTime > uint64(now), BIDDING_END);
        uint256 bidder = userContract.getUserIdIfExist(msg.sender);
        require(isBidder(_auctionId, bidder), NOT_BIDDER);
        require(_amount != uint128(0), AMOUNT_IS_0);
        require(erc20.balanceOf(msg.sender) >= _amount, NOT_ENOUGHT_TOKEN);
        
        Auction storage auction = idToAuction[_auctionId];

        uint128 oldAmount = auction.amount[bidder];

        auction.amount[bidder] += _amount;
        auction.escrowedERC20[bidder] += _amount;

        erc20.transferFrom(msg.sender, address(this), _amount);
        
        assert(auction.amount[bidder] == oldAmount + _amount);
        
        emit AuctionBidded(_auctionId, bidder, _amount, auction.amount[bidder]);
    }
    
    /**
     * @dev Select winner
     * @dev Reverts if auction is not bidding stage
     * @dev Reverts if winner is not bidder
     * @param _auctionId application id
     * @param _winner bidder id
     */
    function selectWinner(uint256 _auctionId, uint256 _winner) 
        external 
        whenNotPaused
        auctionExistAndAtStage(_auctionId, Stages.Bidding)
        isSeller(_auctionId)
    {
        require(isBidder(_auctionId, _winner), INVAL_WINNER_ID);
        
        Auction storage auction = idToAuction[_auctionId];
        
        auction.winner = _winner;
        auction.stage = Stages.WinnerChoosen;

        auction.escrowedERC20[auction.seller] = auction.amount[_winner];
        auction.escrowedERC20[_winner] = 0;
        
        assert(auction.winner == _winner);
        
        emit AuctionWinnerChoosen(_auctionId, _winner);
    }

    /**
     * @dev Withdraw bidded amount for loser or seller
     * @dev Reverts if auction is not winner choosen stage
     * @dev Reverts if already withdrawn
     * @param _auctionId application id
     */
    function withdrawERC20(uint256 _auctionId) 
        external 
        whenNotPaused
        auctionExistAndAtStage(_auctionId, Stages.WinnerChoosen)
    {
        uint256 userId = userContract.getUserIdIfExist(msg.sender);
        require(idToAuction[_auctionId].escrowedERC20[userId] != 0, NO_ESCROWED_TOKEN);

        uint128 amount = idToAuction[_auctionId].escrowedERC20[userId];

        idToAuction[_auctionId].escrowedERC20[userId] = 0;

        erc20.transfer(msg.sender, amount);
    }
    
    /**
     * @dev Kill this smart contract.
     */
    function kill () onlyOwner whenPaused public {
        selfdestruct (owner);
    }
    
}
