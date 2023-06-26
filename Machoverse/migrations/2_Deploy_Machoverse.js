const Machoverse = artifacts.require("Machoverse"); //0x535f3B77418813A5a284Df4d4508631509005599

module.exports = async (deployer) => {
  await deployer.deploy(
    Machoverse,
    "0xf8c2099B8F5403356ACA29cB5aFFf4f861D7fd99",
    "0x61644eaB32eC98620585c2aE3C30B62b73A33E3E"
  );
  console.log("Machoverse Address", Machoverse.address);
};
