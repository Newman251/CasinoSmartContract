pragma solidity ^0.5.2;

contract mortal {
    address payable owner;
    // the deployer of the contract is the owner
    constructor() public { owner = msg.sender; }
    function kill() public { if (msg.sender == owner) selfdestruct(owner); }
}

contract slotGame is mortal{

    

    function randomGenerate(uint mod) internal view returns(uint){
    
            uint randNo = uint(keccak256(abi.encodePacked(
            now,
            block.difficulty,
            msg.sender)
            ))%mod;

        return randNo;
    }

    function value() external view returns(uint){
        return randomGenerate(10);
    }

}