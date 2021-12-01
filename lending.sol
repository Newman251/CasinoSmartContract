// SPDX-License-Identifier: CC-BY-NC-SA-4.0
//TEstline

pragma solidity ^0.5.17;

contract mortal {
    address payable owner;
    // the deployer of the contract is the casino owner
    constructor() public { owner = msg.sender; }
    function kill() public { if (msg.sender == owner) selfdestruct(owner); }
}

contract lending is mortal {
    struct loan {
		address payable account;    // address of broke person
		uint256 amountLended;             // loan amount
		uint256 interestRate;             // casino's profit in percentage
        uint256 amountToPayBack;            // amount that has to be paid back (including interest)
	}

        struct tokenList{
        address userId;     //WalletID of the user. The first wallet is always the casino owner (It is initialized when deploying the contract)
        uint amount;        //Amount of casino tokens a user has in their wallet
    }

    uint256 limit = 100;    //Limit of tokens a user can use as stake at a time
    tokenList[] tokenLists; //The entity of all tokens within the casino
    uint rate = 10;         //conversion rate WEI <=> Casino Token. A Value of 10 means you need 10 WEI to get 1 Token     

    //Initialize the contract. The casino owner deploys the contract by adding Tokens to his account.
    //As he needs to be able to pay a lot of gamblers, he needs a sufficient enough start capital
    constructor (uint casinoInitialisationBalance) public {
        require(casinoInitialisationBalance > 10000, "You must invest more than 10000");
        tokenList memory newTokenList = tokenList(msg.sender, casinoInitialisationBalance/rate);
        tokenLists.push(newTokenList); //The casion owner is inserted as the first entry in the tokenLists
        debtBalances[msg.sender] = 0;  
    }

    //Anyone can buy tokens by putting Ether into the contract.
    function buyTokens() external payable{
        require(msg.value > rate*10, "Too low, cost must be greater than 100");     //At least 10 tokens have to be bought
        require(msg.value <= rate*1000, "Too high, cost must be less than 10000");  //To prevent fraud at maximum 1000 tokens can be bought at the same time

        uint256 tokens = (msg.value/rate);

        //check if the user already has a casino account
        bool userFound;
        for (uint i = 0; i < tokenLists.length; i++) {
            //If the user has already a casino account, add the newly bought tokes to his account
	        if(tokenLists[i].userId == msg.sender){
                  tokenLists[i].amount += tokens;
                  userFound = true;  
            }  
	    }
        //If all accounts belong to other users, create a new one for the new customer and add their tokens
        if(!userFound){
            tokenList memory newTokenList = tokenList(msg.sender, tokens);
            tokenLists.push(newTokenList);
        }
        //userFound = false;
        
    }

    //Return all casino accounts as well as their balances
    function statusAccounts() public view returns (address[] memory, uint256[] memory) {
	    address[] memory allAccounts = new address[](tokenLists.length);
	    uint256[] memory allAmounts = new uint256[](tokenLists.length);
	    
	    for (uint i = 0; i < tokenLists.length; i++) {
	        allAccounts[i] = tokenLists[i].userId;  //Add User ID to the userID-list
	        allAmounts[i] = tokenLists[i].amount;   //Add balance to the balances-list
	    }
	    
	    return (allAccounts, allAmounts);
    }    

    //Get the number of customers. Remember that the casino owner is listed here as well
    function getNumberCustomers() public view returns (uint256){
        return tokenLists.length;
    }

    //Return the accpunt balance for a given wallet ID
    function getAccountBalance(address accountOwner) public view returns (uint256){
        uint256 numCustomers = getNumberCustomers();
        uint256 amount;
        for (uint256 i = 0; i < numCustomers; i++){
            if(tokenLists[i].userId == accountOwner){
                amount = tokenLists[i].amount;
            	}
        }
        return amount;
    }

    //Returns the balance of the person who calls the function
    function getMyAccountBalance() public view returns (uint256){
        getAccountBalance(msg.sender);
    }

	//Make sure the bid is under the casino's stake limit
    function bidIsUnderLimit(uint256 stake) public view returns (bool) {
        if(stake < 1){return false;}
        if(stake > limit){return false;}
        return true;
	}

    //Checks if enough money is in the accounts of the gambler as well as the casino
    function enoughMoneyForBid (uint256 toCheckCasino, uint256 toCheckGambler, address playerID) public view returns (bool) {
        uint256 balanceCasino = getAccountBalance(msg.sender);
        if(toCheckCasino < balanceCasino){return true;}     //If the casino does not have enough tokens, abort
        uint256 balanceGambler = getAccountBalance(playerID);
        if(toCheckGambler <= balanceGambler){return false;} //If the gambler does not have enough tokens, abort
    }

    //For most casino games we need random numbers. Using keccak256 this function generates a number that is in range of {0; maxNum}
    function randomGenerate(uint maxNum) internal view returns (uint){
            uint mod = maxNum;
            uint randNo = uint(keccak256(abi.encodePacked(
            now,
            block.difficulty,
            msg.sender)
            ))%mod;
        return randNo;
    }
     
    loan[] acceptedLoans;
    loan[] requestedLoans;

    address payable owner;
    mapping(address => uint256) debtBalances;

    //constructor () public {
       // debtBalances[msg.sender] = 0;  
    //}
    
   

    function getBalanceOfOwnerAddress() public view returns (uint256) {
		// the token balance of the owner of the contract
        uint256 balance;
        balance = tokenLists[0].amount;
		return balance;
	}

    function getBalanceOfUserAddress() public view returns (uint256) {
		// the balance of the owner of the contract
		// returns the balance of the owner's address outside this contract
		return msg.sender.balance;
	}


    function requestLoan (uint256 amountSuggestion, uint256 interestSuggestion) public payable{
        require(amountSuggestion > 100, "You must lend more than 100");
        require(amountSuggestion < 10000, "You cannot lend more than 10000");
        require(interestSuggestion < 100, "The interest rate needs to be lower than 100");
        require(interestSuggestion > 0, "The interest rate needs to be higher than 0");
        require(getBalanceOfOwnerAddress() > amountSuggestion, "Your requested amount is bigger than what the casino can provide");

        uint256 interest = interestSuggestion;
        uint256 amountLended = amountSuggestion;
        uint256 amountToPayBack = amountSuggestion + (amountSuggestion * interest)/100;
        
        bool foundRequest = false;
        for (uint i = 0; i < requestedLoans.length; i++){
            if (msg.sender == requestedLoans[i].account){
                foundRequest = true;
            }
        }
        if (!foundRequest){
        loan memory newLoan = loan(msg.sender, amountLended, interest, amountToPayBack);
		requestedLoans.push(newLoan);   
        } else {
            require(!foundRequest, "You already requested a loan that hasn't been approved yet");
        }

    }

    function acceptLoan (address payable userAdress, bool accept) public{
        require((accept == false || accept == true), "The value must be either 0 (not accept) or 1 (accept)");
        require(debtBalances[userAdress] == 0, "Your still in debt. Please pay for your past loans first");
        if(accept == true){
            for (uint i = 0; i < requestedLoans.length; i++){
                if (requestedLoans[i].account == userAdress){
                    debtBalances[userAdress] += requestedLoans[i].amountToPayBack;
        
                    // transfer the balance amount to the message sender
                    userAdress.transfer(requestedLoans[i].amountLended);

                    loan memory newLoan = loan(userAdress, requestedLoans[i].amountLended, requestedLoans[i].interestRate, requestedLoans[i].amountToPayBack);
		            acceptedLoans.push(newLoan); 


                    if (requestedLoans.length > 1){
                        delete requestedLoans[i];
                        requestedLoans[i] = requestedLoans[requestedLoans.length-1];
                        delete requestedLoans[requestedLoans.length-1];
                        requestedLoans.length--;
                    } else {
                        delete requestedLoans[i];
                        requestedLoans.length--;
                    }
                
                }
            }
            
        } else {
            for (uint i = 0; i < requestedLoans.length; i++){
                if (requestedLoans[i].account == userAdress){
                    if (requestedLoans.length > 1){
                        delete requestedLoans[i];
                        requestedLoans[i] = requestedLoans[requestedLoans.length-1];
                        delete requestedLoans[requestedLoans.length-1];
                        requestedLoans.length--;
                    } else {
                        delete requestedLoans[i];
                        requestedLoans.length--;
                    }
                }
            }
        }
    }


    function payBack (address myAdress, uint amountInToken) public payable{
        require(amountInToken <= debtBalances[myAdress], "You cannot pay back more than you lent");
        
        uint256 myBalance;

        for (uint i = 0; i < tokenLists.length; i++) {
             if (tokenLists[i].userId == myAdress){
                myBalance = tokenLists[i].amount;
             }
        }
       
        require(myBalance > amountInToken, "You do not have enough money to pay back this amount of money");    
    
        //transfer amount to casino token account
        tokenLists[0].amount += amountInToken;

        //remove amount from my debt
        debtBalances[myAdress] -= amountInToken;

        //remove amount from my casino token account
        for (uint i = 0; i < tokenLists.length; i++) {
            if (tokenLists[i].userId == myAdress){
                tokenLists[i].amount -= amountInToken;
            }
        }

        //remove my loan from acceptedLoans if I paid it back in full
        if (debtBalances[myAdress] == 0){
            for (uint i = 0; i < acceptedLoans.length; i++){
                if (acceptedLoans[i].account == myAdress){
                    if (acceptedLoans.length > 1){
                        delete acceptedLoans[i];
                        acceptedLoans[i] = acceptedLoans[acceptedLoans.length-1];
                        delete acceptedLoans[acceptedLoans.length-1];
                        acceptedLoans.length--;
                    } else {
                        delete acceptedLoans[i];
                        acceptedLoans.length--;
                    }
                }
            }
        } else {
            for (uint i = 0; i < acceptedLoans.length; i++){
                if (acceptedLoans[i].account == myAdress){
                    acceptedLoans[i].amountToPayBack -= amountInToken;
                }
            }
        }
    }


    // get the status of requested loans
	function requestedLoansStatus() public view returns (address[] memory, uint256[] memory, uint256[] memory, uint256[] memory) {
	    address[] memory allAccounts = new address[](requestedLoans.length);
	    uint256[] memory allLoanAmounts = new uint256[](requestedLoans.length);
	    uint256[] memory allInterestRates = new uint256[](requestedLoans.length);
	    uint256[] memory allAmountToPayBack = new uint256[](requestedLoans.length);
	    
	    
	    for (uint i = 0; i < requestedLoans.length; i++) {
	        allAccounts[i] = requestedLoans[i].account;
	        allLoanAmounts[i] = requestedLoans[i].amountLended;
	        allInterestRates[i] = requestedLoans[i].interestRate;
	        allAmountToPayBack[i] = requestedLoans[i].amountToPayBack;
	    }
	    
	    return (allAccounts, allLoanAmounts, allInterestRates, allAmountToPayBack);
	}

    // get the status of accepted loans
    function acceptedLoansStatus() public view returns (address[] memory, uint256[] memory, uint256[] memory, uint256[] memory) {
	    address[] memory allAccounts = new address[](acceptedLoans.length);
	    uint256[] memory allLoanAmounts = new uint256[](acceptedLoans.length);
	    uint256[] memory allInterestRates = new uint256[](acceptedLoans.length);
	    uint256[] memory allAmountToPayBack = new uint256[](acceptedLoans.length);
	    
	    
	    for (uint i = 0; i < acceptedLoans.length; i++) {
	        allAccounts[i] = acceptedLoans[i].account;
	        allLoanAmounts[i] = acceptedLoans[i].amountLended;
	        allInterestRates[i] = acceptedLoans[i].interestRate;
	        allAmountToPayBack[i] = acceptedLoans[i].amountToPayBack;
	    }
	    
	    return (allAccounts, allLoanAmounts, allInterestRates, allAmountToPayBack);
	}
}