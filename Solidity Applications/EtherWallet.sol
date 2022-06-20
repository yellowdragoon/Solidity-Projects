// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract EtherWallet{

    address public owner;

    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }    

    constructor(){
        owner = msg.sender;
    }

    receive() external payable {}

    function send(address _to, uint _value) external onlyOwner
    {
        require(address(this).balance >= _value, "Insufficient funds.");

        (bool sent,) = _to.call{value: _value}("");

        require(sent, "Ether failed to send.");
    }

    function getBalance() external view returns (uint){
        return address(this).balance;
    }


}