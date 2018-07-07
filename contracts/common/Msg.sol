pragma solidity ^0.4.24;


contract Msg {
    
    string internal constant ADDRESS_IS_0 = "Address is 0";
    
    string internal constant NO_USER = "User don't exist";
    
    string internal constant USER_NOT_ACTIVE = "User is not active";

    string internal constant USER_IS_ACTIVE = "User is active";
    
    string internal constant ALREADY_REGISTERED = "Already registered";
    
    string internal constant INVALID_NAME = "Name is wrong";
    
    string internal constant INVAL_COUNTRY = "Country is wrong";
    
    string internal constant INVAL_GENDER = "Gender is wrong";
    
    string internal constant INVAL_BIRTHDAY = "Birthday is wrong";
    
    string internal constant NO_AUCTION = "Auction don't exist";
    
    string internal constant INVALID_STAGE = "Can not execute at current auction stage";
    
    string internal constant NOT_SELLER = "Your addres don't correpond to seller's address";
    
    string internal constant BE_SELLER = "You are seller";
    
    string internal constant TOO_SMALL_DURATION = "Duration is under minimum available range";
    
    string internal constant ANOTHER_AUCTION_HAVING = "Still having another auction";
    
    string internal constant APPLICATION_END = "Applicant time is over";
    
    string internal constant ALREADY_APPLIED = "Already applied";
    
    string internal constant INVAL_APPLICATION_ID = "Applicant ID is wrong";
    
    string internal constant ALREADY_SELECTED = "Already selected";
    
    string internal constant DURATION_IS_0 = "Duration is 0";
    
    string internal constant NOT_APPLICATION_END = "Application end time don't come";
    
    string internal constant BIDDER_IS_EMPTY = "Bidders is empty";
    
    string internal constant BIDDING_END = "Bidding time is over";
    
    string internal constant NOT_BIDDER = "Not bidder";
    
    string internal constant AMOUNT_IS_0 = "Amount is 0";
    
    string internal constant NOT_ENOUGHT_TOKEN = "You don't have enought token";
    
    string internal constant INVAL_WINNER_ID = "Winner ID is wrong";
    
    string internal constant NO_WINNER = "Winner have not be choosen";
    
    string internal constant ONLY_WINNER = "Not winner";
    
    string internal constant ALREADY_APPROVED = "Already approved";
    
    string internal constant INVAL_TOKEN_ID = "Token ID is wrong";

    string internal constant NO_ESCROWED_TOKEN = "No remain token";
    
}