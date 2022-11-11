pragma solidity ^0.8.0;

struct LockInfo{
    uint256 unlockTime;
    uint256 amount;
}
contract Token {
    string public name = "Mytoken";
    string public symbol = "MTN";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    address public owner;


    mapping( address => uint256) _balances;
    mapping( address => mapping( address => uint256)) _allowed;
    mapping( address => bool ) public isFreeze;
    mapping( address => LockInfo[]) public lockup;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    modifier onlyOwner(){
        require( msg.sender == owner,"msg.sender is not owner");
        _;
    }

    modifier notFreeze(address _holder){
        require( isFreeze[_holder] == false );
        _;
    }
    
    constructor() public {
        owner = msg.sender;
        mint(msg.sender,1000000 * 10**decimals);
    }

    function freeze( address _holder ) public onlyOwner returns(bool){
        isFreeze[_holder] = true;
        return true;    
    }

    function unfreeze( address _holder ) public onlyOwner returns(bool){
        isFreeze[_holder] = false;
        return true;
    }

    function mint(address _to, uint256 _value) public onlyOwner returns(bool){
        _mint(_to,_value);
        return true;
    }

    function _mint(address _to, uint256 _value) internal returns(bool){
        _balances[_to] += _value;
        totalSupply += _value;
        emit Transfer( address(0), _to, _value);
        return true;
    }

    function burn(address _from, uint256 _value) public onlyOwner returns(bool){
        _balances[_from] -= _value;
        totalSupply -= _value;
        emit Transfer(_from, address(0), _value);
        return true;
    }

    // _Owner의 락업 리스트를 순회하며, 락업된 수량을 합산하여 리턴
    function lockedBalanceOf(address _owner) public view returns(uint256) {
        uint256 lockedBalance = 0;
        for(uint256 i=0; i< lockup[_owner].length ;i++) {
            lockedBalance += lockup[_owner][i].amount;
        }
        return lockedBalance;
    }

    // _Owner의 락업 리스트를 순회하며, 락업 시간이 지난 토큰을 _balance에 추가
    function unlock(address _owner) public {
        for(uint256 i=0; i< lockup[_owner].length ; ) {
            if(lockup[_owner][i].unlockTime < block.timestamp ){
                _balances[_owner] += lockup[_owner][i].amount;

                // 리스트 마지막에 위치한 정보를 현재 인덱스로 복사
                lockup[_owner][i] = lockup[_owner][lockup[_owner].length-1];
                //리스트 마지막 위치의 정보를 삭제 
                lockup[_owner].pop();
            }
            else{
                i++;
            }
        }
    }
    
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return _balances[_owner] + lockedBalanceOf(_owner);
    }
    
    function transfer(address _to, uint256 _value) public notFreeze(msg.sender) returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public notFreeze(_from) returns (bool success) {
        require( _value <= _allowed[_from][msg.sender]);
        _allowed[_from][msg.sender] -= _value;
        _transfer(_from,_to,_value);
        return true;
    }

    function _transfer(address _from, address _to, uint256 _value ) internal returns(bool){
        
        if( lockup[_from].length > 0){
            unlock(_from);
        }
        require( _value <= _balances[_from]);
        _balances[_from]  -=  _value;
        _balances[_to]    +=  _value;
        emit Transfer(_from, _to, _value);
    }
    
    function approve(address _spender, uint256 _value) public returns (bool success) {
        _allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) public view returns (uint256 remaining){
        return _allowed[_owner][_spender];
    }

    fallback () external payable{
        _mint(msg.sender, msg.value*1000000);
        _lock( msg.sender, msg.value*1000000);
        payable(owner).transfer(msg.value);
    }

    function _lock(address _holder, uint256 _amount) internal returns(bool){
        //구매시점에서 1분후에 사용가능하게
        lockup[_holder].push(
            LockInfo(block.timestamp + 1 minutes, _amount)
        );
        _balances[_holder] -= _amount;
        return true;
    }

    
}
