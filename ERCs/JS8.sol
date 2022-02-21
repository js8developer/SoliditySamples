// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;


// Any contract that follow the ERC20 standard is a ERC20 token.

// ERC20 tokens provide functionalities to

// transfer tokens
// allow others to transfer tokens on behalf of the token holder
// Here is the interface for ERC20.

// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.0/contracts/token/ERC20/IERC20.sol
interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}




// define contract with type
contract JS8Token is IERC20 {

// decide initial totalSupply
    uint public totalSupply = 10000;
// create a mapping to get the balance of any wallet address
    mapping(address => uint) public balanceOf;
// Returns the remaining number of tokens that spender will be allowed to spend on behalf of owner through transferFrom. 
// This is zero by default.
// This value changes when approve or transferFrom are called.
    mapping(address => mapping(address => uint)) public allowance;

// create the name of the token that can be publicly accessed
    string public name = "JS8Token";
// create the symbol - public
    string public symbol = "JS8";
// how many decimals? - public
    uint8 public decimals = 18;


// create function to transfer an amount. Take recipient and amount, returns bool.
// - subtract amount from balance of msg.sender
// - add the amount to the balance of recipient
// - emit a transfer event
// - return
function transfer(address recipient, uint amount) external returns (bool) {
    balanceOf[msg.sender] -= amount;
    balanceOf[recipient] += amount;
    emit Transfer(msg.sender, recipient, amount);
    return true;
}


// create function to approve the spender. Take spender address and amount, returns bool.
// - check to see the allowance amount
// - emit a approval event
// - return
function approve(address spender, uint amount) external returns (bool) {
    allowance[msg.sender][spender] = amount;
    emit Approval(msg.sender, spender, amount);
    return true;
}


// create function to transferFrom sender to recipient a specific amount. returns bool.
// - subtract amount from allowance
// - subtract amount from the senders balance
// - add the amount to the recipients balance
// - emit a transfer from sender to recipient for amount
// - return
function transferFrom(address sender, address recipient, uint amount) external returns (bool) {
    allowance[sender][msg.sender] -= amount;
    balanceOf[sender] -= amount;
    balanceOf[recipient] += amount;
    emit Transfer(sender, recipient, amount);
    return true;
}


// create a function to mint x amount of tokens. expose external
// - assume sender is owner of contract, add amount to balance
// - add amount to exisiting total supply
// - emit transfer from address 0 to msg.sender with amount
function mint(uint amount) external {
    balanceOf[msg.sender] += amount;
    totalSupply += amount;
    emit Transfer(address(0), msg.sender, amount);
}

// create a function to burn x amount of tokens. expose external
// - subtract amount from sender
// - remove amount from total supply
// - emit transfer from msg.sender to address 0 with amount
function burn(uint amount) external {
    balanceOf[msg.sender] -= amount;
    totalSupply -= amount;
    emit Transfer(msg.sender, address(0), amount);
}


}

