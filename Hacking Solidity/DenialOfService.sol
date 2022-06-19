// SPDX-License-Identifier: MIT

pragma solidity ^0.8;


contract KingOfEther{

    address public king;
    uint public currentAmount;

    mapping(address => uint) public balances;

    function claimThrone() external payable{

        require(msg.value > currentAmount, "Not enough Ether offered.");
        require(msg.sender != king, "Already king.");

        // Vulnerable to DOS
        // -----------------

        //(bool sent,) = king.call{value: currentAmount}("");

        //require(sent, "Ether transfer failed.");


        balances[msg.sender] = msg.value;

        king = msg.sender;
        currentAmount = msg.value;

    }


    function withdraw() external{

        require(msg.sender != king, "Current king cannot withdraw.");

        require(balances[msg.sender] > 0, "Have no balance.");

        (bool sent,) = msg.sender.call{value: balances[msg.sender]}("");

        require(sent, "Ether transfer failed.");
    }
}

contract Attack{

    function attack(KingOfEther kingOfEther) external payable
    {
        kingOfEther.claimThrone{value: msg.value}();

    }


}