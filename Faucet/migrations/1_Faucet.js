const Faucet = artifacts.require("MachoFaucet");
const MachoUSD = artifacts.require("MachoUSD");
const MachoMagic = artifacts.require("MachoMagic");
const MachoCoin = artifacts.require("MachoCoin");

module.exports = async (deployer) => {
  await deployer.deploy(MachoUSD);
  await deployer.deploy(MachoMagic);
  await deployer.deploy(MachoCoin);
  await deployer.deploy(
    Faucet,
    MachoUSD.address,
    MachoMagic.address,
    MachoCoin.address
  );
  console.log("Faucet Address", Faucet.address);
};
