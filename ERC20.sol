// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


library SafeMath { 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a); 
      return a - b;  
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
    }

    function div(uint256 a, uint256 b) internal pure returns (bool, uint256) {
            if (b == 0) return (false, 0);
            return (true, a / b);
    }
}

contract ERC20 {
    
    using SafeMath for uint256;

    string public  name; 
    string public  symbol; 
    uint8 public constant decimals = 18; 


    uint256 totalSupply_;
    address ownerCon; 



    constructor(uint256 total,string memory _name,string memory _symbol)  {  
        totalSupply_ = total ;
        name=_name;
        symbol=_symbol;
        balances[msg.sender] = total * 1 ether ;  
        ownerCon = msg.sender;
    } 

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event Transfer(address indexed from, address indexed to, uint tokens);


    modifier onlyOwner  {
        require (msg.sender == ownerCon);
        _;
    }

    mapping(address => uint256) balances; 
    mapping(address => mapping (address => uint256)) allowed;
    mapping(address => bool) allwhitelistedAddresses;  


    modifier isAddressWhitelisted(address _address) {
        require(allwhitelistedAddresses[_address], "Addres is not in the whitelist");
        _;
    }
    
    modifier isAlreadyWhitelisted(address _address) {
        require(!allwhitelistedAddresses[_address], "Address is already added to whitelist");
        _;
    }

    function addAddressTowhitelist(address _addressToWhitelist) public onlyOwner isAlreadyWhitelisted(_addressToWhitelist) {
        allwhitelistedAddresses[_addressToWhitelist] = true;
    }
 

    function totalSupply() public view returns (uint256) {
	return totalSupply_;
    }

    function balanceOf(address inputAddress) public view returns (uint) {
        return balances[inputAddress];
    } 

    function mint(uint increasedAmount) public onlyOwner returns(bool){
        require(increasedAmount > 0);
        balances[msg.sender] = balances[msg.sender].add(increasedAmount);
        totalSupply_ = totalSupply_.add(increasedAmount);
        emit Transfer(address(0), msg.sender, increasedAmount);
        return true;
    }

    function burn (uint burnAmount) public onlyOwner returns(bool){
        require(burnAmount <= balances[msg.sender]);  
        require(burnAmount > 0);
        balances[msg.sender] = balances[msg.sender].sub(burnAmount);
        totalSupply_ = totalSupply_.sub(burnAmount);
        emit Transfer(msg.sender,address(0), burnAmount);
        return true;
    }

    function approve(address approved_addr, uint numTokens) public returns (bool) {
        allowed[msg.sender][approved_addr] = numTokens;
        emit Approval(msg.sender, approved_addr, numTokens);
        return true;
    }
    
    function transfer(address receiver, uint numTokens) public isAddressWhitelisted(receiver) returns (bool) {
        require(numTokens <= balances[msg.sender], "Insufficient Balance in the sender account");
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(msg.sender, receiver, numTokens); 
        return true;
    }



    function allowance(address owner, address token_manger) public view returns (uint) {
        return allowed[owner][token_manger];
    }

    function transferFrom(address owner, address buyer, uint numTokens) public returns (bool) {
        require(numTokens <= balances[owner]);    
        require(numTokens <= allowed[owner][msg.sender]);
        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner, buyer, numTokens);
        return true;
    }

}
