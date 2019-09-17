var Tic = artifacts.require("./TicTacToe.sol")

module.exports = function(deployer) {
    deployer.deploy(Tic);
};