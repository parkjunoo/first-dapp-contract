const assertRevert = require("./assertRevert");
const Lottery = artifacts.require("Lottery");
const expectEvent = require("./expectEvent");

contract("Lottery", function ([deployer, user1, user2]) {
  let lottery;
  let betAmount = 5 * 10 ** 15;
  beforeEach(async () => {
    console.log("before, each");
    lottery = await Lottery.new();
  });

  it("getPot should return current pot", async () => {
    const pot = await lottery.getPot();
    console.log(pot);
    assert.equal(pot, 0);
  });

  describe("Bet", function () {
    it("need faile when the bet moneyy is 0.005 eth", async () => {
      await assertRevert(
        lottery.bet("0xab", { from: user1, value: betAmount })
      );
      //transaction obj = { chainId , value, to ,from, gas, gasPrice }
    });
    it("should put the bet to the Queue with 1bet", async () => {
      let recept = await lottery.bet("0xab", {
        from: user1,
        value: betAmount,
      });
      // 이더를 스마트컨트랙에 보내면 스마트컨트랙에서 이더를 들고 있게 되어 밸런스가 생김
      let pot = await lottery.getPot();
      assert.equal(pot, 0);

      let contractBalance = await web3.eth.getBalance(lottery.address);
      assert.equal(contractBalance, betAmount);
      //check bet info

      let currentBlockNumber = await web3.eth.getBlockNumber();
      let bet = await lottery.getBetInfo(0);

      assert.equal(bet.answerBlockNumber, currentBlockNumber + 3);
      assert.equal(bet.bettor, user1);
      assert.equal(bet.challengers, "0xab");
      //log
      await expectEvent.inLogs(recept.logs, "BET");
    });
  });
});
