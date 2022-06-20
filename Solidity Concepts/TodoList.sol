// SPDX-License-Identifier: MIT

pragma solidity ^0.8;

contract TodoList{

    struct Todo{
        string text;
        bool completed;
    }

    Todo[] public ourList;

    function createItem(string calldata _text) external {
        ourList.push(Todo({
            text: _text,
            completed: false
        }));
    }

    function toggleCompleted(uint _index) external {
        ourList[_index].completed = !ourList[_index].completed;
    }

    function updateText(uint _index, string calldata _newtext) external {
        ourList[_index].text = _newtext;
    }

    function getItem(uint _index) external view returns(string memory, bool){
        Todo storage item = ourList[_index];
        return(item.text, item.completed);
    }





}