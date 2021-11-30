pragma solidity ^0.5.2;

contract mortal {
    address payable owner;
    // the deployer of the contract is the owner
    constructor() public { owner = msg.sender; }
    function kill() public { if (msg.sender == owner) selfdestruct(owner); }
}

contract casino is mortal{
    	
    struct tokenList{
        address userId;
        uint amount;
    }

    uint256 limit = 100;
    tokenList[] tokenLists;
    uint[] slots = new uint[](4);
    uint win;
    uint rate = 10;

    constructor (uint casinoInitialisationBalance) public {

        require(casinoInitialisationBalance > 10000, "You must invest more than 10000");
        tokenList memory newTokenList = tokenList(msg.sender, casinoInitialisationBalance/rate);
        tokenLists.push(newTokenList);
        
    }

    function buyTokens() external payable{

        require(msg.value > rate*10, "Too low, cost must be greater then 100");
        require(msg.value <= rate*1000, "Too high, cost must be less then 10000");

        uint256 tokens;
        tokens = (msg.value/rate);

        if(tokenLists.length==0){
            tokenList memory newTokenList = tokenList(msg.sender, tokens);
            tokenLists.push(newTokenList);
        }
        
        else{

        bool userFound;

        for (uint i = 0; i < tokenLists.length; i++) {
	        if(tokenLists[i].userId == msg.sender){
                  tokenLists[i].amount += tokens;
                  userFound = true;  
            }  
	    }
            if(!userFound){
                tokenList memory newTokenList = tokenList(msg.sender, tokens);
                tokenLists.push(newTokenList);
            }
                 userFound = false;
        }
    }


    function status() public view returns (address[] memory, uint256[] memory) {
	    address[] memory allAccounts = new address[](tokenLists.length);
	    uint256[] memory allAmounts = new uint256[](tokenLists.length);
	    
	    for (uint i = 0; i < tokenLists.length; i++) {
	        allAccounts[i] = tokenLists[i].userId;
	        allAmounts[i] = tokenLists[i].amount;
	    }
	    
	    return (allAccounts, allAmounts);
    }    

    //Additional function
    function getNumberCustomers() public view returns (uint256){
        return tokenLists.length;
    }
    function getAccountBalance(address accountOwner) public view returns (uint256){
        uint256 numCustomers = getNumberCustomers();
        uint256 amount;
        for (uint256 i = 0; i < numCustomers; i++){
            //address currentAccountID = tokenList[i].userId;
            if(tokenLists[i].userId == accountOwner){
                amount = tokenLists[i].amount;
            	}
        }
        return amount;
    }
    function getMyAccountBalance() public view returns (uint256){
        getAccountBalance(msg.sender);
    }

    //Roll Dice
	
    function bidIsUnderLimit(uint256 stake) public view returns (bool) {
        if(stake < 1){return false;}
        if(stake > limit){return false;}
        return true;
	}
    function bidIsValidInput(uint256 guessToCheck) public pure returns (bool) {
        if(guessToCheck < 1){return false;}
        if(guessToCheck > 6){return false;}
        return true;
	}
    //Checks if enough money is in the accounts of the gambler as well as the casino
    function enoughMoneyForBid (uint256 toCheckCasino, uint256 toCheckGambler, address playerID) public view returns (bool) {
        uint256 balanceCasino = getAccountBalance(msg.sender);
        if(toCheckCasino < balanceCasino){return true;}
        uint256 balanceGambler = getAccountBalance(playerID);
        if(toCheckGambler < balanceGambler){return false;}
    }
    function randomGenerate(uint maxNum) internal view returns (uint){
            uint mod = maxNum;
            uint randNo = uint(keccak256(abi.encodePacked(
            now,
            block.difficulty,
            msg.sender)
            ))%mod;
        return randNo;
    }

    function slotRoll() internal view returns (uint){
        uint result = (randomGenerate(10)+1);
        return result;
    }
    function slotRoll2() internal view returns (uint){
        uint result = (randomGenerate(156)%10+1);
        return result;
    }
    function slotRoll3() internal view returns (uint){
        uint result = (randomGenerate(397)%10+1);
        return result;
    }
    function printSlotResults() public view returns (uint[] memory){
        return slots;
    }

    function StartGameRollDice (uint stake) public payable returns(uint[] memory){
        address playerID = msg.sender;
        uint256 numCustomers = getNumberCustomers();
        uint256 index;
        win = 5 * stake;
        for (uint256 i = 0; i < numCustomers; i++){
            //address currentAccountID = tokenList[i].userId;
            if(tokenLists[i].userId == playerID){
                index = i;
            }
        }

        //Check requirements
        require(bidIsUnderLimit(stake), "Your bid is not in the range of allowed bids!");

        slots[0] = slotRoll();
        slots[1] = slotRoll2();
        slots[2] = slotRoll3();

        if (slots[0] == slots[1] && slots[2] != slots[1]){
            tokenLists[index].amount += win; 
            tokenLists[0].amount -= win;
        }
        if (slots[0] == slots[2] && slots[2] != slots[1]){
            tokenLists[index].amount += win; 
            tokenLists[0].amount -= win;
        }
        if (slots[1] == slots[2] && slots[0] != slots[1]){
            tokenLists[index].amount += win; 
            tokenLists[0].amount -= win;
        }
        if (slots[0] == slots[1] && slots[1] == slots[2]){
            win += win*3;
            tokenLists[index].amount += win; 
            tokenLists[0].amount -= win;
        }
        else if (slots[0] != slots[1] && slots[1] != slots[2] && slots[0] != slots[2]){
            tokenLists[0].amount += stake;
            tokenLists[index].amount -= stake;
            win = 0;
        }

        slots[3] = win;

        return (slots);
    }
}