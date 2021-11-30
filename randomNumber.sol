// SPDX-License-Identifier: CC-BY-NC-SA-4.0
//TEstline
pragma solidity ^0.5.5;

contract mortal {
    address payable owner;
    // the deployer of the contract is the owner
    constructor() public { owner = msg.sender; }
    function kill() public { if (msg.sender == owner) selfdestruct(owner); }
}

contract random is mortal{

    uint public randNo;
    uint mod;

        constructor (uint randomNumberModulus) public {
            mod = randomNumberModulus;
        }


    function randomGenerate() external returns(uint){
    
            randNo = uint(keccak256(abi.encodePacked(
            now,
            block.difficulty,
            msg.sender)
            ))%mod;

        return randNo;
    }

}

