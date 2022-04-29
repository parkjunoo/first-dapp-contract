const { assert } = require("chai");
const assertRevert = require("./assertRevert");
const Lottery = artifacts.require("Lottery");
const expectEvent = require("./expectEvent");

contract("Lottery", function ([deployer, user1, user2]) {
  let lottery;
  let betAmount = 5 * 10 ** 15;
  let betAmountBet = new web3.utils.BN("5000000000000000");
  beforeEach(async () => {
    lottery = await Lottery.new();
  });

  it("getPot should return current pot", async () => {
    const pot = await lottery.getPot();
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

  describe("Distribute", function () {
    describe("when the answer is checkable", function () {
      it("전부다 맞았을 때", async () => {
        await lottery.setAnswerForTest(
          "0x61740bacb40467ccc86a6052caa35cb21eb923dd30ab31dc177a42ce6591c6ee",
          { from: deployer }
        );
        await lottery.betAndDistribute("0x12", {
          from: user2,
          value: betAmount,
        }); //1
        await lottery.betAndDistribute("0x13", {
          from: user2,
          value: betAmount,
        }); //2
        await lottery.betAndDistribute("0x61", {
          from: user1,
          value: betAmount,
        }); //3
        await lottery.betAndDistribute("0x12", {
          from: user2,
          value: betAmount,
        }); //4
        await lottery.betAndDistribute("0x12", {
          from: user2,
          value: betAmount,
        }); //5
        await lottery.betAndDistribute("0x12", {
          from: user2,
          value: betAmount,
        }); //6

        let potBefore = await lottery.getPot();
        let user1BalanceBefore = await web3.eth.getBalance(user1);

        let receipt7 = await lottery.betAndDistribute("0x12", {
          from: user2,
          value: betAmount,
        }); //7 -> 유저 1에게 팟머니 증정

        let potAfter = await lottery.getPot();
        let user1BalanceAfter = await web3.eth.getBalance(user1);

        assert.equal(
          potBefore.toString(),
          betAmountBet.add(betAmountBet).toString()
        );
        assert.equal(potAfter.toString(), "0");

        user1BalanceBefore = new web3.utils.BN(user1BalanceBefore);
        assert.equal(
          user1BalanceBefore.add(potBefore).add(betAmountBet).toString(),
          new web3.utils.BN(user1BalanceAfter).toString()
        );
      });
    });
    describe("when the answer is not revealed", function () {
      it("한글자만 맞았을때", async () => {

        await lottery.setAnswerForTest(
          "0x61740bacb40467ccc86a6052caa35cb21eb923dd30ab31dc177a42ce6591c6ee",
          { from: deployer }
        );
        await lottery.betAndDistribute("0x12", {
          from: user2,
          value: betAmount,
        }); //1
        await lottery.betAndDistribute("0x13", {
          from: user2,
          value: betAmount,
        }); //2
        await lottery.betAndDistribute("0x61", {
          from: user1,
          value: betAmount,
        }); //3
        await lottery.betAndDistribute("0x12", {
          from: user2,
          value: betAmount,
        }); //4
        await lottery.betAndDistribute("0x12", {
          from: user2,
          value: betAmount,
        }); //5
        await lottery.betAndDistribute("0x12", {
          from: user2,
          value: betAmount,
        }); //6

        let potBefore = await lottery.getPot();
        let user1BalanceBefore = await web3.eth.getBalance(user1);

        let receipt7 = await lottery.betAndDistribute("0x12", {
          from: user2,
          value: betAmount,
        }); //7 -> 유저 1에게 팟머니 증정

        let potAfter = await lottery.getPot();
        let user1BalanceAfter = await web3.eth.getBalance(user1);

        assert.equal(
          potBefore.toString(),
          betAmountBet.add(betAmountBet).toString()
        );
        assert.equal(potAfter.toString(), "0");

        user1BalanceBefore = new web3.utils.BN(user1BalanceBefore);
        assert.equal(
          user1BalanceBefore.add(potBefore).add(betAmountBet).toString(),
          new web3.utils.BN(user1BalanceAfter).toString()
        );

      });
    });
    describe("when the answer is not reveald limit is passed", function () {
      it("모두다 틀렸을 때", async () => {

        
      });
    });
  });

  describe("isMatch", function () {
    it("need faile when the bet moneyy is 0.005 eth", async () => {
      let blockHash =
        "0x61740bacb40467ccc86a6052caa35cb21eb923dd30ab31dc177a42ce6591c6ee";
      let matchingResult = await lottery.isMatch("0xab", blockHash);
      assert.equal(matchingResult, 0);
    });
  });
});
