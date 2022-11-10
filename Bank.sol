// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract Bank {
    string  public BankName="MyBank";
    uint balance;
    address public owner;

    event Deposit (address from, uint256 value);
    event Withdraw(address to, uint256 value);

    constructor() payable{
        balance=msg.value;
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require( msg.sender == owner,"msg.sender is not owner");
        _;
    }

    function deposit() public payable onlyOwner {
        balance += msg.value;
        emit Deposit(msg.sender, msg.value); 
    }

    function withdraw(uint256 value) public payable onlyOwner {
        balance -=value;
        payable(msg.sender).transfer(value);
        emit Withdraw(msg.sender, value);
    }

    function getBalance() public view returns(uint256){
        return balance;
    }

    fallback () external payable{
        deposit();
    }
}
