// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Lottery {
    address public owner;
    constructor() {
        //배포가 될때 보낸사람을 owner로 저장한다.
        owner = msg.sender;
    } 

    function getSomeValue() public pure returns (uint256 value) {
        return 5;
    }
}
