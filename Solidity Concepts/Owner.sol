// A simple counter app that only the owner can set the count of.
// Using modifiers

// SPDX-License-Identifier: MIT

pragma solidity ^0.8;

contract Owner{

    address public owner;
    uint public counter;

    constructor(uint _count){
        owner = msg.sender;
        counter = _count;
    }

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    function incrementCounter() external {
        counter++;
    }

    function decrementCounter() external {
        counter--;
    }

    function setCount(uint _count) external onlyOwner{
        counter = _count;
    }

    function transferOwner(address _newOwner) external onlyOwner{
        require(_newOwner != address(0));
        owner = _newOwner;
    }


}