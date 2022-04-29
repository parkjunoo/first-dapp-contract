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
    
    bool private mode = false;

    address payable public owner;
    uint256 constant internal BLOCK_LIMIT = 256;
    uint256 constant internal BET_BLOCK_INTERVAL = 3;
    uint256 constant internal BET_AMOUNT = 5 * 10 ** 15;

    uint256 private _pot;
    
    bytes32 public answerForTest ;

    enum BlockStatus {checkable, notRevealed, BlockLimitPassed}
    enum BettingResult {Fail, Win, Draw}

    event BET(uint256 index, address bettor, uint256 amount, bytes1 challenger, uint256 answerBlockNumber);
    event WIN(uint256 index, address bettor, uint256 amount, bytes1 challenger, bytes1 answer, uint256 answerBlockNumber);
    event FAIL(uint256 index, address bettor, uint256 amount, bytes1 challenger, bytes1 answer, uint256 answerBlockNumber);
    event DRAW(uint256 index, address bettor, uint256 amount, bytes1 challenger, bytes1 answer, uint256 answerBlockNumber);
    event REFUND(uint256 index, address bettor, uint256 amount, bytes1 challenger, uint256 answerBlockNumber);

    constructor() {
        //배포가 될때 보낸사람을 owner로 저장한다.
        owner = payable(msg.sender);
    } 

    function getSomeValue() public pure returns (uint256 value) {
        return 5;
    }

    function getPot() public view returns (uint256 pot) {
        return _pot;
    }

    function betAndDistribute(bytes1 challengers) public payable returns (bool result) {
        bet(challengers);
        distribute();

        return true;
    }


    /**
     * @dev
     * @param challengers
     * @return result 함수가 잘 수행되었는지 확인하는 bool 값 
     */

    function bet(bytes1 challengers) public payable returns (bool result) {
        require(msg.value == BET_AMOUNT, "not enough Eth!");
        require(pushBet(challengers), 'Fail to Add a new Bet Info');
        emit BET(_tail - 1, msg.sender, msg.value, challengers, block.number + BET_BLOCK_INTERVAL);
        return true;
    }

    function distribute() public {
        uint256 cur;
        uint256 transferAmount;

        BetInfo memory b;
        BlockStatus currentBlockStatus;
        BettingResult currentBettingResult;

        for(cur= _head; cur < _tail; cur++) {
           b = _bets[cur];
           currentBlockStatus = getBlockStatus(b.answerBlockNumber);

           if(currentBlockStatus == BlockStatus.checkable){
               bytes32 answerBlockHash = getAnswerBlockHash(b.answerBlockNumber);
               currentBettingResult = isMatch(b.challengers, answerBlockHash);

               if(currentBettingResult == BettingResult.Win){
                   transferAmount = transferAfterPayingFee(b.bettor, _pot + BET_AMOUNT);
                   _pot = 0;

                   emit WIN(cur, b.bettor, transferAmount, b.challengers, answerBlockHash[0], b.answerBlockNumber);
               }
               if(currentBettingResult == BettingResult.Fail) {
                   _pot += BET_AMOUNT;
                   
                   emit FAIL(cur, b.bettor, 0, b.challengers, answerBlockHash[0], b.answerBlockNumber);
               }
               if(currentBettingResult == BettingResult.Draw) {
                   transferAmount = transferAfterPayingFee(b.bettor, BET_AMOUNT);
                   emit DRAW(cur, b.bettor, transferAmount, b.challengers, answerBlockHash[0], b.answerBlockNumber);
               }
           }
           if(currentBlockStatus == BlockStatus.notRevealed){

               break;
           }
           if(currentBlockStatus == BlockStatus.BlockLimitPassed){
                transferAmount = transferAfterPayingFee(b.bettor, BET_AMOUNT);
                emit REFUND(cur, b.bettor, transferAmount, b.challengers, b.answerBlockNumber);
               
           }
           popBet(cur);
        }
        _head = cur;
    }

    function transferAfterPayingFee(address payable addr, uint256 amount) internal returns (uint256) {
        // uint256 fee = amount / 100;
        uint256 fee = 0;
        uint256 amountWithOutFee = amount - fee;

        addr.transfer(amountWithOutFee);
        owner.transfer(fee);
        // call, send, transfer transfer() -> 가장안전한 방법
        // send -> 돈을 보내면 false 을 리턴함
        // call -> 단순히 돈만 보내는것이 아니라 특정 트랜잭션을 실행할 수 있음 왠만하면 call을쓰지 말자...

    }

    function setAnswerForTest(bytes32 answer) public returns (bool result){
        require(msg.sender == owner, "Only owner can set");
        answerForTest = answer;
        return true;
    }

    function getAnswerBlockHash(uint256 answerBlockNumber) internal view returns (bytes32 answer){
        return mode ? blockhash(answerBlockNumber): answerForTest;
    }

    /**
        @dev 배팅 글자와 정답 확인
        @param challengers 배팅글자
        @param answer 블락해쉬
        @return 정답결과
     */
    function isMatch(bytes1 challengers, bytes32 answer) public pure returns (BettingResult) {
        bytes1 first1 = challengers;
        bytes1 first2 = challengers;

        bytes1 answer1 = answer[0];
        bytes1 answer2 = answer[0];
        
        first1 = first1 >> 4;
        first1 = first1 << 4;

        answer1 = answer1 >> 4;
        answer1 = answer1 << 4;

        first2 = first2 << 4;
        first2 = first2 >> 4;

        answer2 = answer2 << 4;
        answer2 = answer2 >> 4;

        if(first1 == answer1 && first2 == answer2){
            return BettingResult.Win;
        }
        if(first1 == answer1 || first2 == answer2) {
            return BettingResult.Draw;
        }
        return BettingResult.Fail;
    }

    function getBlockStatus(uint256 answerBlockNumber) internal view returns (BlockStatus) {
        if(block.number > answerBlockNumber && block.number < BLOCK_LIMIT + answerBlockNumber){
            return BlockStatus.checkable;
        }
        if( block.number <= answerBlockNumber ){
            return BlockStatus.notRevealed;
        }
        return BlockStatus.BlockLimitPassed;
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
