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

      //  require(investmentIsOpen, "Investment is closed");

        uint256 tokens;
        tokens = ( rate * msg.value);

        tokenList memory newTokenList = tokenList(msg.sender, tokens);
        tokenLists.push(newTokenList);

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

