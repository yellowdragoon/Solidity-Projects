// A Constant Sum Automated Market Maker

import "./ERC20.sol";

// SPDX-License-Identifier: MIT

pragma solidity ^0.8;

contract CSAMM{

    //Obeys the equation X + Y = k
    //X = total number of token A
    //Y = total number of token B

    ERC20 tokenA;
    ERC20 tokenB;

    uint public amountTokenA;
    uint public amountTokenB;
    uint public totalShares;

    mapping(address => uint) shares;

    function swap(address _tokenIn, uint _amountIn) external {
        if(_tokenIn == address(tokenA)){

            tokenA.transferFrom(msg.sender, address(this), _amountIn);
        }

        else if(_tokenIn == address(tokenB)){
            tokenB.transferFrom(msg.sender, address(this), _amountIn);
        }

        else{
            revert("Invalid token.");
        }
    }


    function addLiqidity(uint _amountA, uint _amountB) external returns(uint){

        tokenA.transferFrom(msg.sender, address(this), _amountA);
        tokenB.transferFrom(msg.sender, address(this), _amountB);

        uint balA = tokenA.balanceOf(address(this));
        uint balB = tokenB.balanceOf(address(this));

        uint dA = balA - amountTokenA;
        uint dB = balB - amountTokenB;

        // Change in balances proportional to change in shares

        // (total balance + balance added)/total balance = (totalShares + shares minted)/totalShares
        // shares minted = balance addded * (totalShares/total balance)

        uint sharesMint = (dA + dB) * (totalShares/(amountTokenA  + amountTokenB));
        require(sharesMint > 0);

        mintShares(msg.sender, sharesMint);

        updateReserves();

        return sharesMint;
    }

    function mintShares(address _minter, uint _numShares) internal returns(bool) {
        require(_numShares > 0);
        shares[_minter] += _numShares;
        totalShares += _numShares;
        return true;
    }

    function burnShares(address _burner, uint _numBurned) internal returns(bool){
        require(shares[_burner] >= _numBurned, "Invalid burn amount");
        require(_numBurned > 0, "Number burned cannot be 0.");

        shares[_burner] -= _numBurned;
        totalShares -= _numBurned;

        return true;
    }

    function removeLiquidity(uint _shares) external returns(uint, uint){

        uint amountRemoveA = (_shares/totalShares) * amountTokenA;
        uint amountRemoveB = (_shares/totalShares) * amountTokenB;

        burnShares(msg.sender, _shares);

        tokenA.transfer(msg.sender, amountRemoveA);
        tokenB.transfer(msg.sender, amountRemoveB);

        updateReserves();

        return(amountRemoveA, amountRemoveB);

    }


    function updateReserves() internal
    {
        amountTokenA = tokenA.balanceOf(address(this));
        amountTokenB = tokenB.balanceOf(address(this));
    }

}

