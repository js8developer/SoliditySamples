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
    uint public decimals = 0; // 18 is the most used decimal but we are using 0 for example sake only!!! simple to write out values etc.
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



contract CryptosICO is Cryptos {
    
    address public admin;
    address payable public depositAddress;
    uint tokenPrice = 0.001 ether; // 1 ETH = 1000 CRPT, 1 CRPT = 0.001 ETH
    uint public hardcap = 300 ether;
    uint public rasiedAmount;
    uint public saleStart = block.timestamp;
    uint public saleEnd = block.timestamp + 604800; // ico ends in one week
    uint public tokenTradeStart = saleEnd + 604800;
    uint public minInvestment = 0.1 ether;
    uint public maxInvestment = 5 ether;
    enum ICOState { beforeStart, running, afterEnd, halted }
    ICOState public state;


    address public cryptosTokenContractAddress;

    event Invest(address investor, uint value, uint tokens);

    

    constructor(address payable _depositAddress){
        admin = msg.sender;
        depositAddress = _depositAddress;
        state = ICOState.beforeStart;
    }


    function invest() payable public returns(bool) {
        state = getCurrentState();
        require(state == ICOState.running, 'This ICO is currently unavailable.');
        require(msg.value >= minInvestment, 'minInvestment = 0.1 ETH'); 
        require(msg.value <= maxInvestment, 'maxInvestment = 5 ETH');
        rasiedAmount += msg.value;
        require(rasiedAmount <= hardcap, 'Hardcap of 300 ETH has been reached.');

        uint tokens = msg.value / tokenPrice;
        balances[msg.sender] += tokens;
        balances[founder] -= tokens;
        depositAddress.transfer(msg.value);

        emit Invest(msg.sender, msg.value, tokens);

        return true;
    }


    receive() payable external {
        invest();
    }


    modifier onlyAdmin() {
        require(msg.sender == admin, 'You are not the admin.');
        _;
    }

    function halt() public onlyAdmin {
        state = ICOState.halted;
    }

    function resume() public onlyAdmin {
        state = ICOState.running;
    }

    function changeDepositAddress(address payable newDepositAddress) public onlyAdmin {
        depositAddress = newDepositAddress;
    }

    function getCurrentState() public view returns(ICOState) {
        if (state == ICOState.halted) {
            return ICOState.halted;
        } else if (block.timestamp < saleStart){
            return ICOState.beforeStart;
        } else if (block.timestamp >= saleStart && block.timestamp <= saleEnd){
            return ICOState.running;
        } else {
            return ICOState.afterEnd;
        }
    }

    function transfer(address to, uint tokens) public override returns(bool success){
        require(block.timestamp > tokenTradeStart);
        super.transfer(to, tokens); // super = Cryptos in this case. see below for example.
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public override returns(bool) {
        require(block.timestamp > tokenTradeStart);
        Cryptos.transferFrom(from, to, tokens);
        return true;
    }

    function burn() public returns(bool) {
        state = getCurrentState();
        require(state == ICOState.afterEnd);
        balances[founder] = 0;
        return true;
    }

}