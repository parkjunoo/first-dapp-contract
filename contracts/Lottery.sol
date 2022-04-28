// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Lottery {
    struct BetInfo {
        uint256 answerBlockNumber;
        address payable bettor;
        bytes1 challengers;
    }
    uint256 private _tail;
    uint256 private _head;
    mapping (uint256 => BetInfo) private _bets;

    address public owner;
    uint256 constant internal BLOCK_LIMIT = 256;
    uint256 constant internal BET_BLOCK_INTERVAL = 3;
    uint256 constant internal BET_AMOUNT = 5 * 10 ** 15;

    uint256 private _pot;
    event BET(uint256 index, address bettor, uint256 amount, bytes1 challenger, uint256 answerBlockNumber);

    constructor() {
        //배포가 될때 보낸사람을 owner로 저장한다.
        owner = msg.sender;
    } 

    function getSomeValue() public pure returns (uint256 value) {
        return 5;
    }

    function getPot() public view returns (uint256 pot) {
        return _pot;
    }


    /**
     * @dev
     * @param challengers
     * @return result 함수가 잘 수행되었는지 확인하는 bool 값 
     */

    function bet(bytes1 challengers) public payable returns (bool result) {
        // check the proper ether is snet;
        require(msg.value == BET_AMOUNT, "not enough Eth!");
        require(pushBet(challengers), 'Fail to Add a new Bet Info');
        // push bet to the queue;
        // emit event;
        emit BET(_tail - 1, msg.sender, msg.value, challengers, block.number + BET_BLOCK_INTERVAL);
        return true;
    }


    function getBetInfo(uint256 index) public view returns (uint256 answerBlockNumber, address bettor, bytes1 challengers){
        BetInfo memory b = _bets[index];
        answerBlockNumber = b.answerBlockNumber;
        bettor = b.bettor;
        challengers = b.challengers;
    }

    function pushBet(bytes1 challengers) internal returns (bool) {
        BetInfo memory b;
        b.bettor = payable(msg.sender);
        b.answerBlockNumber = block.number + BET_BLOCK_INTERVAL;
        b.challengers = challengers;

        _bets[_tail] = b;
        _tail++;
        return true;
    }

    function popBet(uint256 index) internal returns (bool){
        delete _bets[index];
        return true;
    }


}
