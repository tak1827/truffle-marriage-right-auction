const Auction = artifacts.require("./auction/AuctionAction.sol");
const IssueMCT = artifacts.require("./auction/IssueMCT.sol");
const User = artifacts.require("./user/UserAction.sol");
const ERC20 = artifacts.require("./token/MRAToken.sol");
const ERC721 = artifacts.require("./token/MarrageCertificationToken.sol");

const { increaseTime, duration } = require('./helpers/increaseTime')

const BigNumber = web3.BigNumber
const should = require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should();

const EVMThrow = 'invalid opcode'
const EVMRevert = 'VM Exception while processing transaction: revert'

contract('Auction', function([_, owner, seller, winner, loser1, loser2]) {

  let auction;
  let user;
  let erc20;
  let erc721;
  let issuer;

  const DURATION = 60;
  const AUCTION_ID = 100;
  const WINNER_ID = 101;
  const LOSER1_ID = 102;
  const LOSER2_ID = 103;

  describe('Application Stage', function() {

    beforeEach(async function() {

      // Create contracts
      user = await User.new({ from: owner });
      erc20 = await ERC20.new({ from: owner });
      auction = await Auction.new(user.address, erc20.address, { from: seller });

      // Register users
      await user.register('tak', 1, 1, '01012000', {from: seller});
      await user.register('ted', 2, 2, '01012001', {from: winner});
      await user.register('tom', 3, 1, '01012002', {from: loser1});
      await user.register('tim', 1, 2, '01012003', {from: loser2});

    });

    it('Should create auction', async function() {
      await auction.createAuction(DURATION, {from: seller}).should.be.fulfilled;
    });

    it('Should extend auction end', async function() {
      await auction.createAuction(DURATION, {from: seller});
      await auction.extendApplicationEnd(AUCTION_ID, DURATION, {from: seller}).should.be.fulfilled;
    });

    it('Should cancel auction', async function() {
      await auction.createAuction(DURATION, {from: seller});
      await auction.cancelAuction(AUCTION_ID, {from: seller}).should.be.fulfilled;
    });

    it('Should apply auction', async function() {
      await auction.createAuction(DURATION,  {from: seller});
      await auction.apply(AUCTION_ID, {from: winner}).should.be.fulfilled;
    });

    it('Should select bidder', async function() {
      await auction.createAuction(DURATION,  {from: seller});
      await auction.apply(AUCTION_ID, {from: winner});
      await auction.selectBidders(AUCTION_ID, WINNER_ID,  {from: seller}).should.be.fulfilled;
    });

    it('Should bidding start', async function() {
      await auction.createAuction(DURATION,  {from: seller});
      await auction.apply(AUCTION_ID, {from: winner});
      await auction.apply(AUCTION_ID, {from: loser1});
      await auction.apply(AUCTION_ID, {from: loser2});
      await auction.selectBidders(AUCTION_ID, WINNER_ID,  {from: seller});
      await auction.selectBidders(AUCTION_ID, LOSER1_ID,  {from: seller});
      await increaseTime(DURATION);
      await auction.biddingStart(AUCTION_ID, DURATION,  {from: seller}).should.be.fulfilled;
    });

  });

  const WINNER_TOKEN = 1000;
  const LOSER_TOKEN = 100;

  describe('Bidding Stage', function() {

    beforeEach(async function() {

      // Create contracts
      user = await User.new({ from: owner });
      erc20 = await ERC20.new({ from: owner });
      auction = await Auction.new(user.address, erc20.address, { from: seller });

      // Register users
      await user.register('tak', 1, 1, '01012000', {from: seller});
      await user.register('ted', 2, 2, '01012001', {from: winner});
      await user.register('tom', 3, 1, '01012002', {from: loser1});
      await user.register('tim', 1, 2, '01012003', {from: loser2});

      // Application Stage
      await auction.createAuction(DURATION,  {from: seller});
      await auction.apply(AUCTION_ID, {from: winner});
      await auction.apply(AUCTION_ID, {from: loser1});
      await auction.apply(AUCTION_ID, {from: loser2});
      await auction.selectBidders(AUCTION_ID, WINNER_ID,  {from: seller});
      await auction.selectBidders(AUCTION_ID, LOSER1_ID,  {from: seller});
      await increaseTime(DURATION);
      await auction.biddingStart(AUCTION_ID, DURATION, {from: seller});

      // Deposite token
      await erc20.transfer(winner, WINNER_TOKEN, {from: owner});
      await erc20.transfer(loser1, LOSER_TOKEN, {from: owner});

      // Aprove transfer token
      await erc20.approve(auction.address, WINNER_TOKEN, {from: winner});
      await erc20.approve(auction.address, LOSER_TOKEN, {from: loser1});

    });

    it('Should bid', async function() {
      await auction.bid(AUCTION_ID, WINNER_TOKEN, {from: winner}).should.be.fulfilled;
    });

    it('Should select winner', async function() {
      await auction.bid(AUCTION_ID, WINNER_TOKEN, {from: winner});
      await auction.bid(AUCTION_ID, LOSER_TOKEN, {from: loser1});
      await auction.selectWinner(AUCTION_ID, WINNER_ID, {from: seller}).should.be.fulfilled;
    });

    it('Should withdraw from seller', async function() {
      await auction.bid(AUCTION_ID, WINNER_TOKEN, {from: winner});
      await auction.bid(AUCTION_ID, LOSER_TOKEN, {from: loser1});
      await auction.selectWinner(AUCTION_ID, WINNER_ID, {from: seller});
      await auction.withdrawERC20(AUCTION_ID, {from: seller}).should.be.fulfilled;
    });

    it('Should withdraw from loser', async function() {
      await auction.bid(AUCTION_ID, WINNER_TOKEN, {from: winner});
      await auction.bid(AUCTION_ID, LOSER_TOKEN, {from: loser1});
      await auction.selectWinner(AUCTION_ID, WINNER_ID, {from: seller});
      await auction.withdrawERC20(AUCTION_ID, {from: loser1}).should.be.fulfilled;
    });

  });


  describe('Token Issue', function() {

    beforeEach(async function() {

      // Create contracts
      user = await User.new({ from: owner });
      erc20 = await ERC20.new({ from: owner });
      erc721 = await ERC721.new({ from: owner });
      auction = await Auction.new(user.address, erc20.address, { from: seller });
      issuer = await IssueMCT.new(user.address, erc721.address, auction.address, { from: seller });

      // Register users
      await user.register('tak', 1, 1, '01012000', {from: seller});
      await user.register('ted', 2, 2, '01012001', {from: winner});
      await user.register('tom', 3, 1, '01012002', {from: loser1});
      await user.register('tim', 1, 2, '01012003', {from: loser2});

      // Application Stage
      await auction.createAuction(DURATION,  {from: seller});
      await auction.apply(AUCTION_ID, {from: winner});
      await auction.apply(AUCTION_ID, {from: loser1});
      await auction.apply(AUCTION_ID, {from: loser2});
      await auction.selectBidders(AUCTION_ID, WINNER_ID,  {from: seller});
      await auction.selectBidders(AUCTION_ID, LOSER1_ID,  {from: seller});
      await increaseTime(DURATION);
      await auction.biddingStart(AUCTION_ID, DURATION, {from: seller});

      // Deposite token
      await erc20.transfer(winner, WINNER_TOKEN, {from: owner});
      await erc20.transfer(loser1, LOSER_TOKEN, {from: owner});

      // Aprove transfer token
      await erc20.approve(auction.address, WINNER_TOKEN, {from: winner});
      await erc20.approve(auction.address, LOSER_TOKEN, {from: loser1});

      // Bidding Stage
      await auction.bid(AUCTION_ID, WINNER_TOKEN, {from: winner});
      await auction.bid(AUCTION_ID, LOSER_TOKEN, {from: loser1});
      await auction.selectWinner(AUCTION_ID, WINNER_ID, {from: seller});

    });

    it('Should issue token', async function() {
      await issuer.issueERC721Token(AUCTION_ID, {from: seller}).should.be.fulfilled;
    });

  });

});
