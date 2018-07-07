const User = artifacts.require("./user/UserAction.sol");
const ERC20 = artifacts.require("./token/MRAToken.sol");
const ERC721 = artifacts.require("./token/MarrageCertificationToken.sol");
const Crowdsale = artifacts.require("./crowdsale/MRACrowdsale.sol");
const Auction = artifacts.require("./auction/AuctionAction.sol");
const IssueMCT = artifacts.require("./auction/IssueMCT.sol");

module.exports = function(deployer) {

	deployer.then(async () => {

    const erc20 = await deployer.deploy(ERC20);

    const erc721 = await deployer.deploy(ERC721);

    const user = await deployer.deploy(User);

    const auction = await deployer.deploy(Auction, user.address, erc20.address);

    await deployer.deploy(Crowdsale, erc20.address);

    await deployer.deploy(IssueMCT, user.address, erc721.address, auction.address);

  });

};
