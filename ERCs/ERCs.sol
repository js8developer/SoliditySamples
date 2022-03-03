// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


interface IERC20 {
// external view = view-only called by other contracts; not inside same contract.




    // totalSupply
    function totalSupply() external view returns (uint);
    // balanceOf
    function balanceOf(address account) external view returns (uint);
    // transfer
    function transfer(address recipient, address sender, uint amount) external returns (bool);
    // allowance
    function allowance(address owner, address spender, uint amount) external view returns (uint);
    // approve
    function approve(address spender, uint amount) external returns (bool);
    // transferFrom
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    // Transfer
    event Transfer(address indexed sender, address indexed recipient, uint value);
    // Approval
    event Approval(address indexed owner, address indexed spender, uint value);
  


  
}