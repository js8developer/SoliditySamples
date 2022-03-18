// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.9.0;


interface ERC20Interface {
    // Only these 3 functions are mandatory to be implemented in the contract that inherits this!
    function totalSupply() external view returns(uint);
    function balanceOf(address tokenOwner) external view returns(uint balance);
    function transfer(address to, uint tokens) external returns(bool success);

    // these are considered optional!
    function allowance(address tokenOwner, address spender) external view returns(uint remaining);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
    
    // 
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}









interface ERC20 {
    function totalSupply() external view returns(uint);
    function balanceOf(address account) external view returns(uint);
    function transfer(address to, uint amount) external returns(bool);

    function approve(address sender, uint amount) external returns(bool);
    function allowance(address owner, address spender) external returns(uint);
    function transferFrom(address from, address to, uint amount) external returns(uint);

    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed owner, address indexed spender, uint amount);

}

contract TestToken is ERC20Interface {

    string public name = "TestToken";
    string public symbol = "TEST";
    uint public decimals = 0; // 18
    uint public totalSupply;

    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowed;

    address payable contractExternalOwnerAccount;

    constructor(){
        contractExternalOwnerAccount = payable(msg.sender);
        totalSupply = 1000;
        balances[contractExternalOwnerAccount] = totalSupply;
    }


    function balanceOf(address account) public view returns(uint) {
        return balances[account];
    }

    function transfer(address to, uint tokens) public returns(bool) {
        require(balanceOf(contractExternalOwnerAccount) >= tokens, "Sorry, there are not enough tokens to carry out this transaction.");
        require(to != msg.sender, "Sorry, you cannot transfer tokens to yourself.");
        balances[contractExternalOwnerAccount] -= tokens;
        balances[to] += tokens;
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender) public view returns(uint) {
        return allowed[tokenOwner][spender];
    }


    function approve(address spender, uint tokens) public returns(bool){
        require(balanceOf(msg.sender) >= tokens, "Sorry, there are not enough tokens to carry out this transaction.");
        require(tokens > 0, "You must send more than 0 tokens.");
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    // Called by the sprender (to) address. This is why we need to check if they have already been approved by the from
    // wallet address. You should not be able to spend somebody else's money without their permission! That's what this function checks
    // for and carries out.
    function transferFrom(address from, address to, uint amount) public returns(bool){
        require(allowed[from][to] >= amount, "Sorry, you are not approved to transfer this amount.");
        require(balanceOf(from) >= amount, "Sorry, there are not enough tokens to carry out this transaction.");
        balances[from] -= amount;
        balances[to] += amount;
        allowed[from][to] -= amount;
        emit Transfer(from, to, amount);
        return true;
    }
}