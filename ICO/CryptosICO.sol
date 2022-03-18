// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.9.0;

import { Cryptos } from "./Cryptos.sol";


// alex golding | delphi digital

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

    // Events to send to front end.
    event Invest(address investor, uint value, uint tokens);

    
    constructor(address payable _depositAddress){
        admin = msg.sender;
        depositAddress = _depositAddress;
        state = ICOState.beforeStart;
    }


    receive() payable external {
        invest();
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