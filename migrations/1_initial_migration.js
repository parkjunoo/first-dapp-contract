const Migrations = artifacts.require("Migrations");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
};

// migrations 의 폴더 1,2,3, 순으로 배포가 진행됨 (rule base)
