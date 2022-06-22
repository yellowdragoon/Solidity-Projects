//Let's create an multi-sig wallet. Here are the specifications.

//The wallet owners can
//-----------------------
//submit a transaction
//approve and revoke approval of pending transcations
//anyone can execute a transcation after enough owners has approved it.


// SPDX-License-Identifier: MIT

pragma solidity ^0.8;

contract MultiSigWallet {
    event Deposit(address indexed sender, uint amount, uint balance);
    event SubmitTransaction(
        address indexed owner,
        uint indexed txIndex,
        address indexed to,
        uint value,
        bytes data
    );
    event ConfirmTransaction(address indexed owner, uint indexed txIndex);
    event RevokeConfirmation(address indexed owner, uint indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint indexed txIndex);

    address[] public owners;
    mapping(address => bool) isOwner;
    uint public requiredApprovals;

    struct Transaction{
        address to;
        uint value;
        bytes data;
        bool executed;
    }

    Transaction[] public transactions;

    mapping(uint => mapping(address => bool)) public approvals;

    constructor(uint _requiredApprovals, address[] memory _owners)
    {
        require(_owners.length > 0, "Invalid number of owners.");
        require(_requiredApprovals <= _owners.length && _requiredApprovals > 0, "Invalid number of approvals.");

        requiredApprovals = _requiredApprovals;
        
        for (uint index = 0; index < _owners.length; index++)
         {
            address owner = _owners[index];
            require(owner != address(0), "Owner invalid.");
            require(!isOwner[owner], "Duplicate owner.");

            owners.push(owner);
            isOwner[owner] = true;
        }
    }


    modifier onlyOwner() {
        require(isOwner[msg.sender]);
        _;
    }

    modifier txExists(uint _txIndex) {
        require(_txIndex < transactions.length);
        _;
    }

    modifier notExecuted(uint _txIndex) {
        require(!transactions[_txIndex].executed);
        _;
    }

    modifier notConfirmed(uint _txIndex) {
        require(!approvals[_txIndex][msg.sender]);
        _;
    }


    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    function submitTransaction(
        address _to,
        uint _value,
        bytes memory _data
    ) public onlyOwner
    {
        transactions.push(Transaction(_to, _value, _data, false));
        emit SubmitTransaction(msg.sender, transactions.length - 1, _to, _value, _data);
    }

    function confirmTransaction(uint _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
        notConfirmed(_txIndex)
    {
        approvals[_txIndex][msg.sender] = true;
        emit ConfirmTransaction(msg.sender, _txIndex);
    }

    function getApprovalCount(uint _txIndex) private view returns(uint) {
        uint count = 0;

        for (uint256 index = 0; index < owners.length; index++)
        {
            if (approvals[_txIndex][owners[index]]) {
                count++;
            } 
        }
        return count;
    }

    function executeTransaction(uint _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
    {
        require(getApprovalCount(_txIndex) >= requiredApprovals);

        Transaction storage transaction = transactions[_txIndex];

        transaction.executed = true;
        (bool executed,) = transaction.to.call{value: transaction.value}(transaction.data);

        require(executed);

        emit ExecuteTransaction(msg.sender, _txIndex);
    }

    function revokeConfirmation(uint _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
    {
        require(approvals[_txIndex][msg.sender]);
        approvals[_txIndex][msg.sender] = false;

        emit RevokeConfirmation(msg.sender, _txIndex);
    }

    function getOwners() public view returns (address[] memory) {
        return owners;
    }

    function getTransactionCount() public view returns (uint) {
        return transactions.length;
    }

    function getTransaction(uint _txIndex)
        public
        view
        txExists(_txIndex)
        returns (
            address to,
            uint value,
            bytes memory data,
            bool executed,
            uint numConfirmations
        )
    {
        Transaction storage transaction = transactions[_txIndex];
        return (
                transaction.to,
                transaction.value,
                transaction.data,
                transaction.executed,
                getApprovalCount(_txIndex)
        );
    }
}