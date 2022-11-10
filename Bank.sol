pragma solidity ^0.8.0;
contract Token {
    string public name = "Mytoken";
    string public symbol = "MTN";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping( address => uint256) _balances;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
    constructor() public {
        totalSupply = 10000 * 10**decimals;
        _balances[msg.sender] = totalSupply;
    }
    
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return _balances[_owner];
    }
    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require( _value <= _balances[msg.sender]);
        _balances[msg.sender]  -=  _value;
        _balances[_to]         +=  _value;
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
         require( _value <= _balances[_from]);
				 _balances[_from]  -=  _value;
         _balances[_to]    +=  _value;
         return true;
    }
    
    function approve(address _spender, uint256 _value) public returns (bool success) {
    
    }
    
    function allowance(address _owner, address _spender) public view returns (uint256 remaining){
    }

    
}
