var LiefToken = artifacts.require("LiefToken");

module.exports = function(deployer) {
    deployer.deploy(LiefToken);
};