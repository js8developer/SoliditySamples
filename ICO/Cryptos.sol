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


contract Cryptos is ERC20Interface {
    string public name = "Cryptos";
    string public symbol = "CRPT";
    uint public decimals = 0; // 18
    uint public override totalSupply;

    address public founder;
    mapping(address => uint) public balances;

    mapping(address => mapping(address => uint)) allowed;
    // ox1111 (owner) allows 0x222 (spender) to withdraw 100 tokens from the owners acct
    // allowed[0x111][0x222] = 100;

    constructor(){
        totalSupply = 1000000;
        founder = msg.sender;
        balances[founder] = totalSupply;
    }

    function balanceOf(address tokenOwner) public view override returns(uint balance){
        return balances[tokenOwner];
    }

    function transfer(address to, uint tokens) public override virtual returns(bool success){
        require(balances[msg.sender] >= tokens, 'The sender does not have enough tokens to give.');
        require(to != msg.sender, "Sorry, you cannot send tokens to yourself.");
        balances[to] += tokens;
        balances[msg.sender] -= tokens;
        emit Transfer(msg.sender, to, tokens);
        return true;
    }


    function allowance(address tokenOwner, address spender) view public override returns(uint) {
        return allowed[tokenOwner][spender];
    }

    function approve(address spender, uint tokens) public override returns (bool){
        require(balanceOf(msg.sender) >= tokens, 'You do not have enough tokens to approve this amount.');
        require(tokens > 0);

        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);

        return true;
    }

    // This function is called by the spender, who wants to withdraw X amount of tokens
    // from the holders account. It checks with the approved values to make sure that
    // this user has been approved to do this by the other user. If allowed by the holder, 
    // we then need to adjust these values accordingly.
    function transferFrom(address from, address to, uint tokens) public virtual override returns(bool) {
        require(allowed[from][to] >= tokens, 'You have not been approved to withdraw this amount from the holder.');
        require(balanceOf(from) >= tokens, 'The holder does not have enough tokens for this txn.');
        
        balances[to] += tokens;
        balances[from] -= tokens;

        allowed[from][to] -= tokens;

        return true;
    }

}