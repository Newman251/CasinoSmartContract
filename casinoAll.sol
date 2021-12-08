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
    
    struct loan {
		address payable account;    // address of broke person
		uint256 amountLended;             // loan amount
		uint256 interestRate;             // casino's profit in percentage
        uint256 amountToPayBack;            // amount that has to be paid back (including interest)
	}
     
    loan[] acceptedLoans;
    loan[] requestedLoans;

    address payable owner;
    mapping(address => uint256) debtBalances;
    
    //Initialize the contract. The casino owner deploys the contract by adding Tokens to his account.
    //As he needs to be able to pay a lot of gamblers, he needs a sufficient enough start capital
    constructor () public payable {
        require(msg.value > 10000, "You must invest more than 10000");
        tokenList memory newTokenList = tokenList(msg.sender, msg.value/rate);
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
    function getNumberCustomers() internal view returns (uint256){
        return tokenLists.length;
    }

    //Return the account balance for a given wallet ID
    function getAccountBalance(address anyAccount) public view returns (uint256){
        uint256 numCustomers = getNumberCustomers();
        uint256 amount;
        for (uint256 i = 0; i < numCustomers; i++){
            if(tokenLists[i].userId == anyAccount){
                amount = tokenLists[i].amount;
            	}
        }
        return amount;
    }

    //Returns the balance of the person who calls the function
    function getMyAccountBalance() internal view returns (uint256){
        getAccountBalance(msg.sender);
    }

	//Make sure the bid is under the casino's stake limit
    function bidIsUnderLimit(uint256 stake) internal view returns (bool) {
        if(stake < 1){return false;}
        if(stake > limit){return false;}
        return true;
	}

    //Checks if enough money is in the accounts of the gambler as well as the casino
    function enoughMoneyForBid (uint256 toCheckCasino, uint256 toCheckGambler, address playerID) internal view returns (bool) {
        uint256 balanceCasino = tokenLists[0].amount;
        if(toCheckCasino > balanceCasino){return false;}       //If the casino does not have enough tokens, abort
        uint256 balanceGambler = getAccountBalance(playerID);
        if(toCheckGambler > balanceGambler){return false;}      //If the gambler does not have enough tokens, abort
        return true;
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
        require(enoughMoneyForBid (stake*9, stake, playerID),  "Either you or the casino do not have enough tokens to perform this game!");
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
    function bidIsValidInput(uint256 guessToCheck) internal pure returns (bool) {
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

// ---------------------Blackjack Functions--------------------------------------

    string[] possibleCards = ["2","3","4","5","6","7","8","9","10", "Jack","Queen", "King", "Ace"];
    uint[] possibleValues =  [ 2,  3,  4,  5,  6,  7,  8,  9,  10,   10,     10,     10,     11];

    //A BlackJack game consists of the player ID, the cards the dealer has on his table, the gamber's cards and the stakte the two parties play for
    struct blackJackGame{
        address playerID;
        uint256[] dealerCards;
        uint256[] gamblerCards;
        uint256 stake;
    }
    
    //Initialize the blackjack game table, where all the games will be stored
    blackJackGame[] blackJackGames; 

    //returns the length of the game table (how many games were started so far)
    function getNumberBlackjackGames() private view returns (uint256){
        return blackJackGames.length;
    }

    //One player can only play one game at a time. We need to check whether another game is still running
    function noGameRunning(address playerID) private view returns (bool){
        for (uint256 i = 0; i < getNumberBlackjackGames(); i++){     //Determine if there is a game by this player
            if(blackJackGames[i].playerID == playerID){
                return false;   //If a game by this player is found "false" is returned
            }
        }
        return true;            //No game was found, so we can return true
    }

    //This function determines on which position of the game array the currently played game is
    function getGameIndex(address playerID) private view returns (uint256){
        require(noGameRunning(playerID) == false);      //If there is no game, no index can be returned
        uint256 gameIndex = 0;
        for (uint256 i = 0; i < getNumberBlackjackGames(); i++){     
            if(blackJackGames[i].playerID == playerID){
                gameIndex = i;
                return gameIndex;
            }
        }
    }

    //This function returns a random number between 0 and 12 which represents our cards
    function getRandomCard() private view returns (uint256){
        uint cardResult = randomGenerate(12);
        return cardResult;
    }

    //This function takes the index of the card and returns its name. It is NOT used right now
    function getNameOfCard(uint256 cardIndex) private view returns (string memory){
        return possibleCards[cardIndex];
    }

    //This function takes the playerID and returns its wallet ID
    function getIndexOfGambler(address playerID) private view returns (uint256){
        uint256 index;          
        uint256 numCustomers = getNumberCustomers();                        
        for (uint256 i = 0; i < numCustomers; i++){                         //Determine the index of the gambler in the tokenLists
            if(tokenLists[i].userId == playerID){
                index = i;
            }
        }
        return index;
    }

    //This function is the start to a blackjack game. It distributes the first cards.
    //We simplified blackjack a bit: Every card is there infinite times, and an Ace is always worth 11.
    function StartGameBlackjack (uint256 stake) public{
        address playerID = msg.sender;                      //The player is the one who started the game
        require(enoughMoneyForBid(stake, stake, playerID), "Someone does no have suffiecient funds"); //Every party has to have enough tokens to perform the results of the game
        tokenLists[0].amount -= stake;                      //Substract stake from the casino's accounts, it is now in the game 
        uint256 playerTokenID = getIndexOfGambler(msg.sender);//Get the index of the gambler in the tokenLists
        tokenLists[playerTokenID].amount -= stake;          //Substract the stake from the gambler's account
        uint256[] memory dealerCardsNew = new uint256[](1); //At first the dealer gets one card
        uint256[] memory gamblerCardsNew = new uint256[](2);//The gambler gets two cards
        
        require(noGameRunning(playerID), "You already play a game");//Anyone can only play one game at a time
        uint256 playerIndex;                                    //The users index in the casino's tokenLists
        for (uint256 i = 0; i < getNumberCustomers(); i++){     //Determine the index of the gambler in the tokenLists
            if(tokenLists[i].userId == playerID){
                playerIndex = i;
            }
        }
            
        gamblerCardsNew[0] = getRandomCard(); //draw first card
        gamblerCardsNew[0] = getRandomCard(); //draw second card
        dealerCardsNew[0] = getRandomCard();  //draw dealer's card

        //Create a new game entry and push it to the Games-List. After that it's the player's choice to draw a card or stand.
        blackJackGame memory game = blackJackGame(msg.sender, dealerCardsNew, gamblerCardsNew, stake);
        blackJackGames.push(game);
    }

    //This function deletes a game (after it finished)
    function deleteGame(uint256 gameIndex) private{
        //blackJackGames[gameIndex] = blackJackGames[blackJackGames.length - 1];
        //delete blackJackGames[blackJackGames.length - 1];
        //blackJackGames.length--;
       delete blackJackGames[gameIndex];
    }

    //If the gambler loses, the casino gets the money from the bet and the game is deleted
    function lost(uint256 gameIndex, uint256 stake) private{
        tokenLists[0].amount += 2*stake;
        deleteGame(gameIndex);
    }

    //If the gambler wins, they get the money from the bet and the game is deleted
    function win(uint256 gameIndex, address gamblerAddress, uint256 stake) private{
        uint256 index = getIndexOfGambler(gamblerAddress);
        tokenLists[index].amount += 2*stake;
        deleteGame(gameIndex);
    }

    //If there is a tie, the casino and the gamber get their stake back and the game is deleted 
    function tie(uint256 gameIndex, address gamblerAddress, uint256 stake) private{
        uint256 index = getIndexOfGambler(gamblerAddress);
        tokenLists[0].amount += stake;
        tokenLists[index].amount += stake;
        deleteGame(gameIndex);
    }

    //This function can be called by the gambler to draw one more card.
    function draw1Card() public{
        require(noGameRunning(msg.sender) == false); 
        uint256 gameIndex = getGameIndex(msg.sender);
        uint256 newCardValue = getRandomCard();
        blackJackGames[gameIndex].gamblerCards.push(newCardValue);//Add the new card to the game
        if(calculateValueOfHand(gameIndex, true) == 21){win(gameIndex, msg.sender, blackJackGames[gameIndex].stake);}//if they reached 21, they directly win
        if(calculateValueOfHand(gameIndex, true) > 21){lost(gameIndex, blackJackGames[gameIndex].stake);}//If they have more than 21, they directly lose
    }

    //This function calculates the value of a hand for gambler or dealer for a given game index
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
            entireValue += possibleValues[valuesIndizes[i]];    //the cards have specified values that come from the table above
        }
        return entireValue;
    }

    //This function returns the current game status of the gambler including both their value and the one of the dealer
    function calculateBothHands() public view returns(uint256[2] memory){
        uint256 gameIndex = getGameIndex(msg.sender);
        uint256[2] memory returnValues;
        returnValues[0] = calculateValueOfHand(gameIndex, true); //The value of the gambler's cards
        returnValues[1] = calculateValueOfHand(gameIndex, false);//The value of the dealer's card(s)
        return (returnValues);
    }

    //This function returns the current game status of any stated gambler including both their value and the one of the dealer
    function calculateBothHands(uint256 gameIndex) private view returns(uint256[2] memory){
        uint256[2] memory returnValues;
        returnValues[0] = calculateValueOfHand(gameIndex, true);
        returnValues[1] = calculateValueOfHand(gameIndex, false);
        return (returnValues);
    }

    //Only for devellopping: All Handy can be shown
    function getAllHands() private view returns(uint[] memory, uint[] memory){
        uint256[] memory handsGamblers = new uint256[](blackJackGames.length);
        uint256[] memory handsDealer = new uint256[](blackJackGames.length);
        for(uint256 i; i < blackJackGames.length; i++){
            uint256[2] memory bothHands = calculateBothHands(i);
            handsGamblers[i] = bothHands[0];
            handsDealer[i] = bothHands[1];
        }
        return (handsGamblers, handsDealer);
    }

    //This function adds one card to the dealer's repertoire
    function draw1CardDealer(uint256 gameIndex) private{
        uint256 newCardValue = getRandomCard();
        blackJackGames[gameIndex].dealerCards.push(newCardValue); 
    }

    //This function can be called by the gambler to not draw any more cards. The game is finished from here.
    function stand() public{
        uint256 gameIndex = getGameIndex(msg.sender);
        while(calculateValueOfHand(gameIndex, false)<17){       //If the dealer has cards worth less than 17 they have to draw more card(s)
            draw1CardDealer(gameIndex);
        }
        uint256 valueGambler = calculateValueOfHand(gameIndex, true);       //The value of the gambler's cards is calculated
        uint256 valueDealer = calculateValueOfHand(gameIndex, false);       //The value of the dealer's cards is calculated
        if(valueDealer > 21){win(gameIndex, msg.sender, blackJackGames[gameIndex].stake);}                  //If the dealer has more than 21, the gambler wins
        else{
            if(valueGambler > valueDealer){win(gameIndex, msg.sender, blackJackGames[gameIndex].stake);}    //If the gambler's cards's worth is higher, the gambler wins
            if(valueGambler < valueDealer){lost(gameIndex, blackJackGames[gameIndex].stake);}               //If the dealers's cards's worth is higher, the gambler loses
            if(valueGambler < valueDealer){tie(gameIndex, msg.sender, blackJackGames[gameIndex].stake);}    //If the gambler's cards's worth is the same as the dealer's, they tie
        }
    }
    
   
    // the token balance of the owner of the contract (the casino)
    function getBalanceOfOwnerAddress() public view returns (uint256) {
		
        uint256 balance;
        balance = tokenLists[0].amount;
		return balance;
	}


    // requesting Loan by proposing an amount and interest rate 
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

    // the casino can accept a Loan request by inserting the players address and a boolean (true = accept) and (false = reject)
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

    // pay back your loan by inserting your own account address and the amount you would like to pay back
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