// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Bank {

    string constant public BankName="MyBank";
    mapping(address => uint256) _balances;
    address owner;

    event Deposit ( address from, uint256 value);
    event Withdraw( address to, uint256 value);


    constructor() payable{
        _balances[msg.sender] = msg.value;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner,"transaction sender is not owner");
        _;
    }

    function deposit() public payable {

        _balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 value) public payable  {
        _balances[msg.sender] -=value;
        payable(msg.sender).transfer(value);
    }

    function balanceOf(address _owner) public view returns(uint256) {
        return _balances[_owner];
    }

    fallback() external payable{
        deposit();
    }
    
}
