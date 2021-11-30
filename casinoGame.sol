pragma solidity ^0.5.5;

contract casinoGame{
    struct balance{
        address payable userId;
        uint amount;
    }
    balance[] tokenList;
    //mapping (uint256 => balance) tokenList;

    bool gameIsOpen;
    string gameName;
    address casino;
    uint guess;
    uint256 limit = 100;

    constructor (string memory gameNameIn) public {
        casino = msg.sender;
        gameName = gameNameIn;

        //Only for testing
        addCustomer(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, 1000);
        addCustomer(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2, 200);
    }
    function addCustomer(address payable userID, uint amount) public {
        balance memory newCustomer = balance(userID, amount);
        tokenList.push(newCustomer);
    }
    function getNumberCustomers() public view returns (uint256){
        return tokenList.length;
    }
    function getAccountBalance(address accountOwner) public view returns (uint256){
        uint256 numCustomers = getNumberCustomers();
        uint256 amount;
        for (uint256 i = 0; i < numCustomers; i++){
            //address currentAccountID = tokenList[i].userId;
            if(tokenList[i].userId == accountOwner){
                amount = tokenList[i].amount;
            	}
        }
        return amount;
    }
    function getGameName () public view returns (string memory) {
        return gameName;
    }
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
    function randomGenerate(uint maxNum) internal view returns (uint){
            uint mod = maxNum;
            uint randNo = uint(keccak256(abi.encodePacked(
            now,
            block.difficulty,
            msg.sender)
            ))%mod;
        return randNo;
    }
    function rollDice() public view returns (uint){
        uint diceResult = randomGenerate(6);
        diceResult += 1;
        return diceResult;
    }

    function StartGameRollDice (address playerID, uint guessIn, uint stake) public{
        guess = guessIn;
        uint256 numCustomers = getNumberCustomers();
        uint256 index;
        for (uint256 i = 0; i < numCustomers; i++){
            //address currentAccountID = tokenList[i].userId;
            if(tokenList[i].userId == playerID){
                index = i;
            }
        }

        //Check requirements
        require(bidIsUnderLimit(stake), "Your bid is not in the range of allowed bids!");
        require(bidIsValidInput(guess), "Please enter a valid entry!");


        uint diceResult = 0;//TBD: Enter random number here
        diceResult = rollDice();
        //guess = 5; //TBD: Enter user guess here

        uint256 win = 5 * stake;

        if(diceResult == guess){
            tokenList[index].amount += win; 
            tokenList[0].amount -= win;
        }
        else{
            tokenList[0].amount += stake;
            tokenList[index].amount -= stake;
        }
    }
}