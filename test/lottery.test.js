const Lottery = artifacts.require("Lottery");

contract("Lottery", function ([deployer, user1, user2]) {
  beforeEach(async () => {
    console.log("before, each");
    Lottery = await Lottery.new();
  });
  it("Basic_test", async () => {
    console.log("Basic test");
    const owner = await Lottery.owner();
    const value = await Lottery.getSomeValue();
    console.log(owner);
    console.log(value);
    assert.equal(10, 10);
  });
});
