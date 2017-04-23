var DMVContract = artifacts.require("FloridaDepartmentOfMotorVehicles");

module.exports = function(deployer) {
  deployer.deploy(DMVContract);
};
