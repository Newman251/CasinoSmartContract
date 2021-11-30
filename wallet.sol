// SPDX-License-Identifier: CC-BY-NC-SA-4.0
//TEstline
pragma solidity ^0.5.2;

contract mortal {
    address payable owner;
    // the deployer of the contract is the owner
    constructor() public { owner = msg.sender; }
    function kill() public { if (msg.sender == owner) selfdestruct(owner); }
}

contract bank is mortal{
    	
    struct tokenList{
        address userId;
        uint amount;
    }

    tokenList[] tokenLists;

    uint rate = 10;

    function buyTokens() external payable{

        require(msg.value > rate*10, "Too low, cost must be greater then 100");
        require(msg.value <= rate*200, "Too high, cost must be less then 2000");

        uint256 tokens;
        //uint256 ownerBalance;
        tokens = (msg.value/rate);

        // constructor (string memory ownerBalanceIn) public {
        //     owner = msg.sender;
        //     ownerBalance = ownerBalanceIn;
        //  }
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

}

