const Migrations = artifacts.require("myERC721");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
};
