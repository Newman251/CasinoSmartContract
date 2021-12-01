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
    constructor (uint casinoInitialisationBalance) public {
        require(casinoInitialisationBalance > 10000, "You must invest more than 10000");
        tokenList memory newTokenList = tokenList(msg.sender, casinoInitialisationBalance/rate);
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
        if (slots[0] == slots[1] && slots[2] != slots[1]){
            tokenLists[index].amount += winSlots; 
            tokenLists[0].amount -= winSlots;
        }
        if (slots[0] == slots[2] && slots[2] != slots[1]){
            tokenLists[index].amount += winSlots; 
            tokenLists[0].amount -= winSlots;
        }
        if (slots[1] == slots[2] && slots[0] != slots[1]){
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

// ---------------------Blackjack Functions--------------------------------------

    string[] possibleCards = ["2","3","4","5","6","7","8","9","Jack","Queen", "King", "Ace"];
    uint[] possibleValues =  [ 2,  3,  4,  5,  6,  7,  8,  9,  10,    10,      10,     11  ];

    struct blackJackGame{
        address playerID;
        uint256[] dealerCards;
        uint256[] gamblerCards;
        uint256 stake;
    }
    

    blackJackGame[] blackJackGames;// = new blackJackGame[](10);

    function getNumberBlackjackGames() private view returns (uint256){
        return blackJackGames.length;
    }

    function noGameRunning(address playerID) private view returns (bool){
        for (uint256 i = 0; i < getNumberBlackjackGames(); i++){     //Determine if there is a game by this player
            if(blackJackGames[i].playerID == playerID){
                return false;
            }
        }
        return true;
    }
    function getGameIndex(address playerID) private view returns (uint256){
        uint256 gameIndex = 0;
        for (uint256 i = 0; i < getNumberBlackjackGames(); i++){     
            if(blackJackGames[i].playerID == playerID){
                gameIndex = i;
                return gameIndex;
            }
        }
        return gameIndex;
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function getRandomCard() private view returns (uint256){
        uint cardResult = randomGenerate(11);
        return cardResult;
    }
    function getNameOfCard(uint256 cardValue) private view returns (string memory){
        return possibleCards[cardValue];
    }

    function getIndexOfGambler(address playerID) private view returns (uint256){
        uint256 index;          
        uint256 numCustomers = getNumberCustomers();                        //The users index in the casino's tokenLists
        for (uint256 i = 0; i < numCustomers; i++){                         //Determine the index of the gambler in the tokenLists
            if(tokenLists[i].userId == playerID){
                index = i;
            }
        }
        return index;
    }

    function StartGameBlackjack (uint256 stake) public{
    address playerID = msg.sender; 
    require(enoughMoneyForBid(stake, stake, playerID));
    tokenLists[0].amount -= stake; //Substract stake, it is in the game newTokenList
    uint256 playerTokenID = getIndexOfGambler(msg.sender);
    tokenLists[playerTokenID].amount -= stake;
    uint256[] memory dealerCardsNew = new uint256[](1);
    uint256[] memory gamblerCardsNew = new uint256[](2);
    
    require(noGameRunning(playerID), "You already play a game");
    uint256 playerIndex;                                    //The users index in the casino's tokenLists
    for (uint256 i = 0; i < getNumberCustomers(); i++){     //Determine the index of the gambler in the tokenLists
        if(tokenLists[i].userId == playerID){
            playerIndex = i;
        }
    }
        
    //draw first card
    gamblerCardsNew[0] = getRandomCard();
    //draw second card
    gamblerCardsNew[0] = getRandomCard();
    //draw dealer card
    dealerCardsNew[0] = getRandomCard();

    blackJackGame memory game = blackJackGame(msg.sender, dealerCardsNew, gamblerCardsNew, stake);
    blackJackGames.push(game);
    }
    function deleteGame(uint256 gameIndex) private{
        //blackJackGames[gameIndex] = blackJackGames[blackJackGames.length - 1];
        //delete blackJackGames[blackJackGames.length - 1];
        //blackJackGames.length--;
       delete blackJackGames[gameIndex];
    }

    function lost(uint256 gameIndex, uint256 stake) private{
        tokenLists[0].amount += 2*stake;
        deleteGame(gameIndex);
    }

    function win(uint256 gameIndex, address gamblerAddress, uint256 stake) private{
        uint256 index = getIndexOfGambler(gamblerAddress);
        tokenLists[index].amount += 2*stake;
        deleteGame(gameIndex);
    }

    function tie(uint256 gameIndex, address gamblerAddress, uint256 stake) private{
        uint256 index = getIndexOfGambler(gamblerAddress);
        tokenLists[0].amount += stake;
        tokenLists[index].amount += stake;
        deleteGame(gameIndex);
    }

    function draw1Card() public{
        uint256 gameIndex = getGameIndex(msg.sender);
        uint256 newCardValue = getRandomCard();
        blackJackGames[gameIndex].gamblerCards.push(newCardValue);
        if(calculateValueOfHand(gameIndex, true) == 21){win(gameIndex, msg.sender, blackJackGames[gameIndex].stake);}
        if(calculateValueOfHand(gameIndex, true) > 21){lost(gameIndex, blackJackGames[gameIndex].stake);}
    }

    function calculateValueOfHand(uint256 gameIndex, bool gambler) private view returns (uint256){
        uint256[] memory valuesIndizes;
        if(gambler){
            valuesIndizes = blackJackGames[gameIndex].gamblerCards;
        }
        else{
            valuesIndizes = blackJackGames[gameIndex].dealerCards;
        }
        uint256 entireValue = 0;
        for (uint256 i=0; i<valuesIndizes.length; i++){
            entireValue += possibleValues[valuesIndizes[i]];
        }
        return entireValue;
    }
    function calculateBothHands(uint gameIndex) public view returns(uint256[2] memory){
        uint256[2] memory returnValues;
        returnValues[0] = calculateValueOfHand(gameIndex, true);
        returnValues[1] = calculateValueOfHand(gameIndex, false);
        return (returnValues);
    }
    function getAllHands() public view returns(uint[] memory, uint[] memory){
        uint256[] memory handsGamblers = new uint256[](blackJackGames.length);
        uint256[] memory handsDealer = new uint256[](blackJackGames.length);
        for(uint256 i; i < blackJackGames.length; i++){
            uint256[2] memory bothHands = calculateBothHands(i);
            handsGamblers[i] = bothHands[0];
            handsDealer[i] = bothHands[1];
        }
        return (handsGamblers, handsDealer);
    }

    function draw1CardDealer(uint256 gameIndex) private{
        uint256 newCardValue = getRandomCard();
        blackJackGames[gameIndex].dealerCards.push(newCardValue); 
    }

    function stand() public{
        uint256 gameIndex = getGameIndex(msg.sender);
        while(calculateValueOfHand(gameIndex, false)<17){
            draw1CardDealer(gameIndex);
        }
        uint256 valueGambler = calculateValueOfHand(gameIndex, true);
        uint256 valueDealer = calculateValueOfHand(gameIndex, false);
        if(valueDealer > 21){win(gameIndex, msg.sender, blackJackGames[gameIndex].stake);}
        else{
            if(valueGambler > valueDealer){win(gameIndex, msg.sender, blackJackGames[gameIndex].stake);}
            if(valueGambler < valueDealer){lost(gameIndex, blackJackGames[gameIndex].stake);}
            if(valueGambler < valueDealer){tie(gameIndex, msg.sender, blackJackGames[gameIndex].stake);}
        }
    }

}