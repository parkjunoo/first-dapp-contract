module.exports = async (promise) => {
  try {
    await promise;
    assert.fail("experted revert not recived");
  } catch (err) {
    const revertFound = err.message.search("revert") >= 0;
    assert(revertFound, `Expected "revert", get ${err} instead`);
  }
};
