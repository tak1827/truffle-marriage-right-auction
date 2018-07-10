const MRAToken = artifacts.require("./token/MRAToken.sol");
const MRACrowdsale = artifacts.require("./crowdsale/MRACrowdsale.sol");

contract('MRACrowdsale', function([_, owner, buyer, recipient]) {

  let crowdsale;
  let erc20;

  beforeEach(async function() {

    // Create contracts
    erc20 = await MRAToken.new({ from: owner });
    crowdsale = await MRACrowdsale.new(erc20.address, {from: owner});

    // Deposite token to crowdsale
    let totalSupply = await erc20.totalSupply();
    let crowdHoldToken = totalSupply.toNumber() / 1000;
    await erc20.transfer(crowdsale.address, crowdHoldToken, {from: owner});
  });

  // Buy token
  it('Should buy token', async function() {
    let payment = 1000;
    await web3.eth.sendTransaction({from: buyer, to: crowdsale.address, value: payment});

    let balance = await erc20.balanceOf(buyer);
    assert(balance.toNumber() === payment, 'Token should be bought');
  });


  // Buy token for recipient
  it('Should buy token for other account', async function() {
    let payment = 1000;
    await crowdsale.buyTokens(recipient, {from: buyer, value: payment});

    let balance = await erc20.balanceOf(recipient);
    assert(balance.toNumber() === payment, 'Token should be bought for recipient');
  });

});
