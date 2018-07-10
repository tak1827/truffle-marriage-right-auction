const User = artifacts.require("./user/UserAction.sol");

const BigNumber = web3.BigNumber
const should = require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should();

const EVMThrow = 'invalid opcode'
const EVMRevert = 'VM Exception while processing transaction: revert'

contract('UserAction', function([_, owner, account1, account2]) {

  let user;

  beforeEach(async function() {

    // Create contracts
    user = await User.new({ from: owner });
  });

  it('Should register user', async function() {
    await user.register('tak', 1, 1, '01012000', {from: account1}).should.be.fulfilled;
  });

  it('Should update user', async function() {
    await user.register('tak', 1, 1, '01012000', {from: account1});
    await user.update('ted', 2, 2, '01012020', {from: account1}).should.be.fulfilled;
  });

  it('Should change user address', async function() {
    await user.register('tak', 1, 1, '01012000', {from: account1});
    await user.changeUserAddress(account2, {from: account1});
    await user.getUserIdIfExist(account2, {from: account1}).should.be.fulfilled;
  });

  it('Should resign user', async function() {
    await user.register('tak', 1, 1, '01012000', {from: account1});
    await user.resign({from: account1});
    await user.getUserIdIfExist(account1, {from: account1}).should.be.rejectedWith(EVMRevert);
  });

});
