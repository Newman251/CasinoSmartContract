pragma solidity ^0.5.2;

contract mortal {
    address payable owner;
    // the deployer of the contract is the owner
    constructor() public { owner = msg.sender; }
    function kill() public { if (msg.sender == owner) selfdestruct(owner); }
}

contract casino is mortal{
    struct tokenList{
        address userId;     //WalletID of the user. The first wallet is always the casino owner (It is initialized when deploying the contract)
        uint amount;        //Amount of casino tokens a user has in their wallet
    }

    uint256 limit = 100;    //Limit of tokens a user can use as stake at a time
    tokenList[] tokenLists; //The entity of all tokens within the casino
    uint rate = 10;         //conversion rate WEI <=> Casino Token. A Value of 10 means you need 10 WEI to get 1 Token     

    //Initialize the contract. The casino owner deploys the contract by adding Tokens to his account.
    //As he needs to be able to pay a lot of gamblers, he needs a sufficient enough start capital
    constructor () public payable {
        require(msg.value > 10000, "You must invest more than 10000");
        tokenList memory newTokenList = tokenList(msg.sender, msg.value/rate);
        tokenLists.push(newTokenList); //The casion owner is inserted as the first entry in the tokenLists
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
    function status() public view returns (address[] memory, uint256[] memory) {
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
    //withdraw function for exchanging tokens to currency
    function withdraw() public{
    uint256 amountToTransfer;
        for (uint i = 0; i < tokenLists.length; i++) {
	        if(tokenLists[i].userId == msg.sender){ //finding the user who wants to withdraw
                  amountToTransfer = tokenLists[i].amount;
                  tokenLists[i].amount = 0;
                  msg.sender.transfer(amountToTransfer*rate); //sending back the amount of wei owed (tokens * rate)
                }  
	        }
    	}

// ---------------------Slots Functions--------------------------------------

    uint[] slots = new uint[](4); //Declaring slot results array
    uint winSlots; //Win amount variable declared
//Three different slot roll functions are requred to generate different results for each slot
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
//function which prints the results from the slot roll in form |S|S|S|Winning
    function printSlotResults() public view returns (uint[] memory){
        return slots;
    }
//Starting slot game Functions
    function StartGameSlots (uint stake) public{
        address playerID = msg.sender;                  //ID of the player
        uint256 numCustomers = getNumberCustomers();    //The number of users registered in the casino
        uint256 index;                                  //The users index in the casino's tokenLists
        winSlots = 3 * stake;                           //If you match two numbers, you recieve 3 times the stake
        for (uint256 i = 0; i < numCustomers; i++){      //Determine the index of the gambler in the tokenLists
            if(tokenLists[i].userId == playerID){
                index = i;
            }
        }

        //Check requirement
        require(bidIsUnderLimit(stake), "Your bid is not in the range of allowed bids!");
        //getting result for each slot
        slots[0] = slotRoll();
        slots[1] = slotRoll2();
        slots[2] = slotRoll3();
        //if statements for checking if two numbers on the slot machine match
        if (slots[0] == slots[1] && slots[2] != slots[1] || slots[0] == slots[2] && slots[2] != slots[1] || slots[1] == slots[2] && slots[0] != slots[1]){
            tokenLists[index].amount += winSlots; 
            tokenLists[0].amount -= winSlots;
        }
        //chekcing if all three slot results match (x9 the stake)
        if (slots[0] == slots[1] && slots[1] == slots[2]){
            winSlots += winSlots*3;
            tokenLists[index].amount += winSlots; 
            tokenLists[0].amount -= winSlots;
        }
        //if no matches, user pays casino owner
        else if (slots[0] != slots[1] && slots[1] != slots[2] && slots[0] != slots[2]){
            tokenLists[0].amount += stake;
            tokenLists[index].amount -= stake;
            winSlots = 0;
        }

        slots[3] = winSlots; //assigning the third slot to display the users winnings
    }


// ---------------------Dice Functions--------------------------------------

    //For rolling the dice, a bid x needs to be part of {1,2,3,4,5,6}
    function bidIsValidInput(uint256 guessToCheck) public pure returns (bool) {
        if(guessToCheck < 1){return false;}
        if(guessToCheck > 6){return false;}
        return true;
	}

    //This function "rolls a dice", thus returns a random number in range of {1,2,3,4,5,6}
    function rollDice() public view returns (uint){
        uint diceResult = randomGenerate(6);
        diceResult += 1; //As randomGenerate returns {0,; 5} we need to shift the output by 1
        return diceResult;
    }

    //Play the game Roll Dice
    function StartGameRollDice (uint guessIn, uint stake) public{
        address playerID = msg.sender;                  //ID of the player
        uint guess = guessIn;                           //Guess of the user (what they expect the dice to show after rolling)
        uint256 numCustomers = getNumberCustomers();    //The number of users registered in the casino
        uint256 win = 5 * stake;                        //The possible win for the gambler (For the game to be fair you get 6 times the amount you put on the bet)
        uint256 index;                                  //The users index in the casino's tokenLists
        for (uint256 i = 0; i < numCustomers; i++){     //Determine the index of the gambler in the tokenLists
            if(tokenLists[i].userId == playerID){
                index = i;
            }
        }

        //Check requirements
        require(enoughMoneyForBid(win, stake, playerID));                                   //The gambler has to have enough tokens as well as the casino
        require(bidIsUnderLimit(stake), "Your bid is not in the range of allowed bids!");   //Make sure the bid is under the casino's stake limit
        require(bidIsValidInput(guess), "Please enter a valid entry!");                     //For rolling the dice, a bid x needs to be part of {1,2,3,4,5,6}

        uint diceResult = rollDice(); //The dice's value ist computed and assigned

        //If the gambler guessed the value correctly he wins the "win" amount that is then added to his balance and taken from the casino owner's account
        if(diceResult == guess){
            tokenLists[index].amount += win; 
            tokenLists[0].amount -= win;
        }
        //If the gabmler did not guess the value correctly, he loses his stake which then gets added to the casino owner's balance
        else{
            tokenLists[0].amount += stake;
            tokenLists[index].amount -= stake;
        }
    }

// ----------------------------------Roulette Functions-------------------------------------
    uint rouletteNumber;
    string rouletteColour;
    uint winRoulette;

    function printRouletteNumber() public view returns (uint){
        return rouletteNumber;
    }
    function printRouletteColour() public view returns (string memory){
        return rouletteColour;
    }
    function printRouletteWinnings() public view returns (uint){
        return winRoulette;
    }


    function StartGameRoulette (uint number, string memory colour, uint stake) public {

    require(number > 0, "You must guess between 1 and 36"); //If number is too low
    require(number <= 36 , "You must guess between 1 and 36"); //If number is too high
    //checking to see if the colour guess is right
    require(keccak256(bytes(colour)) == keccak256(bytes("r")) || keccak256(bytes(colour)) == keccak256(bytes("b"))  , "You must guess either red 'r' or black 'b'");
    require(bidIsUnderLimit(stake), "Your bid is not in the range of allowed bids!"); //checking if stake is ok

        address playerID = msg.sender; //same as dice
        uint256 numCustomers = getNumberCustomers(); //same as dice
        uint256 index; //same as Dice
        uint colourMatchMmultiplier;
        uint numberMatchMmultiplier;
        winRoulette = stake; //initialising winnings as the stake
        colourMatchMmultiplier = 2; //multiplier is 2 for correct colour
        numberMatchMmultiplier = 30; //multiplier is 30 fir correct number
        for (uint256 i = 0; i < numCustomers; i++){ //check number of customers
            if(tokenLists[i].userId == playerID){
                index = i;
            }
        }
        uint rOrB; 
        rOrB = randomGenerate(2) + 1; //generating random colour
        if(rOrB == 1){rouletteColour = "r";}else{rouletteColour = "b";} //converting to colour
        rouletteNumber = randomGenerate(37); //generating random number (0-36)

        if (keccak256(bytes(colour)) == keccak256(bytes(rouletteColour))){ //assigning winnings if colour guessed right
            winRoulette = winRoulette*colourMatchMmultiplier;
            tokenLists[index].amount += winRoulette; 
            tokenLists[0].amount -= winRoulette;
        }
        if (number == rouletteNumber){// assigning winning if number guessed right
            winRoulette = winRoulette*numberMatchMmultiplier;
            tokenLists[index].amount += winRoulette; 
            tokenLists[0].amount -= winRoulette;
        }
//if both colour and number are guessed right, multiply winnings by two
        if (number == rouletteNumber && keccak256(bytes(colour)) == keccak256(bytes(rouletteColour))){ 
            winRoulette = 2*(winRoulette*colourMatchMmultiplier + winRoulette*numberMatchMmultiplier);
            tokenLists[index].amount += winRoulette; 
            tokenLists[0].amount -= winRoulette;
            tokenLists[index].amount += winRoulette; 
            tokenLists[0].amount -= winRoulette;
        }
//check to see if user has lost then subtract the stake if so
        if (number != rouletteNumber && (keccak256(bytes(colour)) != keccak256(bytes(rouletteColour)))){
            tokenLists[0].amount += stake;
            tokenLists[index].amount -= stake;
            winRoulette = 0;
        }
    }
}
