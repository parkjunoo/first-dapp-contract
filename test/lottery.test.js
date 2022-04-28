const Lottery = artifacts.require("Lottery");

contract("Lottery", function ([deployer, user1, user2]) {
  let lottery;
  beforeEach(async () => {
    console.log("before, each");
    lottery = await Lottery.new();
  });

  it("Basic test", async () => {
    console.log("Basic test");
    const owner = await lottery.owner();
    const value = await lottery.getSomeValue();
    console.log(owner);
    console.log(value);
    assert.equal(value, 10);
  });

  it.only("getPot should return current pot", async () => {
    const pot = await lottery.getPot();
    console.log(pot);
    assert.equal(pot, 0);
  });
});
