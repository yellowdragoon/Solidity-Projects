// SPDX-License-Identifier: MIT

// A piggy bank contract that anyone can deposit into but only the owner can destroy and take all the ethers.

pragma solidity ^0.8;

contract PiggyBank{

    address public owner;

    event Deposit(uint amount);
    event Withdraw(uint amount);


    constructor()
    {
        owner = msg.sender;
    }


    receive() external payable 
    {
        emit Deposit(msg.value);
    }


    function withdraw() external 
    {
        require(msg.sender == owner, "Only the owner can destroy the piggy bank.");
        emit Withdraw(address(this).balance);
        selfdestruct(payable(owner));
    }

    function getBalance() external view returns(uint)
    {
        return(address(this).balance);
    }


}