var InsurerContract = artifacts.require("Insurer");
var DMVContract = artifacts.require("DMV");

module.exports = function(deployer) {
  deployer.deploy(DMVContract,"Ontario");
};
