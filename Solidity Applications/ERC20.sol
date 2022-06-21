// A standard ERC20 token interface and implementation for Ethereum

// SPDX-License-Identifier: MIT

pragma solidity ^0.8;

interface IERC20{

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns(bool);

    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed owner, address indexed spender, uint amount);
}

contract ERC20 is IERC20{

    uint public totalSupply;

    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowances;

    //metadata about the ERC20 token
    string public name = "DragoonCoin";
    string public symbol = "DROOC";
    uint8 public decimals = 18; //10^18 is equal to one of this token

    function balanceOf(address account) external view returns (uint){
        return balances[account];
    }

    function transfer(address recipient, uint amount) external returns (bool){
        balances[msg.sender] -= amount; //Overflow/Underflow in Solidity 0.8 protects against any funny business
        balances[recipient] += amount; 
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint){
        return(allowances[owner][spender]);
    }

    //Approve someone else to spend X amount of your tokens

    function approve(address spender, uint amount) external returns (bool){
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    //Spending someone else's tokens

    function transferFrom(address sender, address recipient, uint amount) external returns(bool){
        allowances[sender][msg.sender] -= amount;
        balances[sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    //Following 2 functions not part of the ERC20 standard, but commonly used

    function mint(uint amount) external {
        balances[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    function burn(uint amount) external{
        balances[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

}
