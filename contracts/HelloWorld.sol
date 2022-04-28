// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract HelloWorld {
    string public str;
    constructor (string memory _str) public {
        str = _str;
    }
    function setStr(string memory _str) public {
        str = _str;
    }

    function getStr() public view returns (string memory _str){
        return str;
    }
}
