pragma solidity ^0.5.2;

contract casinoGame{
    struct tokenList{
        uint userId;
        uint amount;
    }
    balance[] tokenList;
    tokenList = [(msg.sender,200), (2,1000)];//Position 0 is Casino

    bool gameIsOpen;
    string gameName;

    constructor (string memory gameName) public {
        casino = msg.sender;
        gameName = gameName;
    }

    function getGameName public view returns (uint256) {
        return gameName;
    }

    function StartGameRollDice (uint playerID) public{
        index = TBD;
        diceResult = 0;//TBD: Enter random number here
        guess = 5; //TBD: Enter user guess here
        win = 0;

        if(diceResult == guess){
            tokenList[index][1] += win; 
        }
        else{
            tokenList[0][1] += win;
        }
    }
}