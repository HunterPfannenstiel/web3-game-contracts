const Faucet = artifacts.require("MachoFaucet"); //0x76dE2003a8Ed56fcd27Cb469Afda083E8817f609
const MachoUSD = artifacts.require("MachoUSD"); //0x905DadcAC06C5fBe50D176B54ED062f804dfBE1C
const MachoMagic = artifacts.require("MachoMagic"); //0xC11F0F3E7F18747f7A8cf9fDB371B40d2962083f
const MachoCoin = artifacts.require("MachoCoin"); //0x9D85F23FA51c6690a019ad79F042B313EA618697

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
