// A constant product automated market maker.
// It follows the following function:
// X * Y = k

import "./ERC20.sol";

// SPDX-License-Identifier: MIT

pragma solidity ^0.8;

contract CPAMM{

    uint reserveA;
    uint reserveB;

    ERC20 tokenA;
    ERC20 tokenB;

    uint totalSupply; //i.e. total number of shares

    mapping(address => uint) shareholders; // for LPs

    function swap() external {



    }

    function addLiquidity() external
    {

    }

    function removeLiquidity() external {

    }

    function updateReserves() internal {

    }





}