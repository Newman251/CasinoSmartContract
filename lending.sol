// SPDX-License-Identifier: CC-BY-NC-SA-4.0
//TEstline

import "@nomiclabs/buidler/console.sol";
pragma solidity ^0.5.2;

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
     
    loan[] loans;

    address payable owner;
    mapping(address => uint256) debtBalances;

    constructor () public {
        debtBalances[msg.sender] = 0;  
    }
    
   

    function getBalanceOfOwnerAddress() public view returns (uint256) {
		// the actual balance of the owner of the contract
		return owner.balance;
	}

    function getBalanceOfUserAddress() public view returns (uint256) {
		// the balance of the owner of the contract
		// returns the balance of the owner's address outside this contract
		return msg.sender.balance;
	}


    function requestLoan (uint256 amountSuggestion, uint256 interestSuggestion) external payable{
        require(amountSuggestion < 100, "You must lend more than 100");
        require(interestSuggestion > 10000, "You cannot lend more than 10000");
        require(getBalanceOfOwnerAddress() > msg.value, "The casino cannot fund your request. Lower the amount of the Loan");

        uint256 interest = interestSuggestion;
        uint256 amountLended = amountSuggestion;
        uint256 amountToPayBack = (msg.value * interest)/100;
        bool accept;

        if (acceptLoan(accept) == true){
            loan memory newLoan = loan(msg.sender, amountLended, interest, amountToPayBack);
		    loans.push(newLoan);
        
            debtBalances[msg.sender] += amountToPayBack;
        
            // transfer the balance amount to the message sender
            msg.sender.transfer(amountLended);
        } else {
            console.log("Your loan request was rejected", msg.sender);
        }
        
    }

    function acceptLoan (bool accept) pure public returns(bool){
        return accept;
    }


    function payBack () external payable{
        require(msg.value < debtBalances[msg.sender], "You cannot pay back more than you lent");
        require(getBalanceOfUserAddress() >= msg.value, "You do not have enough money to pay back this amount of money");
        
        owner.transfer(msg.value);
        debtBalances[msg.sender] -= msg.value;
    }


    // get the status of the loans
	function status() public view returns (address[] memory, uint256[] memory, uint256[] memory, uint256[] memory) {
	    address[] memory allAccounts = new address[](loans.length);
	    uint256[] memory allLoanAmounts = new uint256[](loans.length);
	    uint256[] memory allInterestRates = new uint256[](loans.length);
	    uint256[] memory allDebtBalances = new uint256[](loans.length);
	    
	    
	    for (uint i = 0; i < loans.length; i++) {
	        allAccounts[i] = loans[i].account;
	        allLoanAmounts[i] = loans[i].amountLended;
	        allInterestRates[i] = loans[i].interestRate;
	        allDebtBalances[i] = debtBalances[loans[i].account];
	    }
	    
	    return (allAccounts, allLoanAmounts, allInterestRates, allDebtBalances);
	}
}