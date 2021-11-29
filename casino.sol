// SPDX-License-Identifier: CC-BY-NC-SA-4.0
//TEstline
pragma solidity ^0.5.5;

contract mortal {
    address payable owner;
    // the deployer of the contract is the owner
    constructor() public { owner = msg.sender; }
    function kill() public { if (msg.sender == owner) selfdestruct(owner); }
}

contract Oracle{
    address admin;
    uint public rand;

    constructor() public {
        admin = msg.sender;
    }

    function feedRandomness(uint _rand) external{
    require(msg.sender == admin);
    rand = _rand;
    }
}


contract random {
    Oracle oracle;
    uint nonce;
    uint public randNo;

    constructor(address oracleAddress) public{
        oracle = Oracle(oracleAddress);
    }

    function _randModulus(uint mod) internal returns(uint){
        uint rand = uint(keccak256(abi.encodePacked(
            nonce,
            oracle.rand(),
            now,
            block.difficulty,
            msg.sender)
            ))%mod;
            nonce++;
        return rand;
    }

        function foo() external{
        randNo = _randModulus(10);

    }
}

