const Migrations = artifacts.require("myERC20");
const Migration2 = artifacts.require("BouncerProxy");


module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(Migration2);
};
