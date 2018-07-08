# truffle-marriage-right-auction

This ethereum smart contract is public auction of marriage right. People can sell own marriage right to buyer. 
This idea seems to be crazy. But potential demand exist for who can not decide there partner. Auction is efficient way.


## Getting Started

This project is using truffle. So, Need to be installed in advance.
Then, install depencencies.

```
npm install
```

## Auction processing flow

At first, seller or buyer create your own account. Then, seller open auction.
The auction is devided into 3 stages, "Application", "Bidding" and "WinnerChoosen".

**Applicatio Stage** <br>
Buyer apply their participation to the auction, then seller choose budders. Seller can reject undesired buyer.
Only this stage, seller can cansel auction.

**Bidding Stage** <br>
Selected buyers are bidding by ERC20 token called "MarrageRightAuction" token. Buyer can obtain this token through crowdsale.
Note that the auction winner is not the hightest bidder. The winner is choosen by seller. The bidded amount is nothing but one factor.

**WinnerChoosen Stage** <br>
ERC721 Marriage certification token is issued to auction seller and winner.
Losers can withdraw their escrowed token at bidding stage.


## Author

* tak - <re795h@gmail.com> -
