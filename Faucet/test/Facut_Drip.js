const Faucet = artifacts.require("MachoFaucet");
const MachoUSD = artifacts.require("MachoUSD");
const MachoMagic = artifacts.require("MachoMagic");
const MachoCoin = artifacts.require("MachoCoin");

contract("Faucet", (accounts) => {
  let _machoUSD;
  let _machoMagic;
  let _machoCoin;
  let _faucet;
  before(async () => {
    _machoUSD = await MachoUSD.deployed();
    _machoMagic = await MachoMagic.deployed();
    _machoCoin = await MachoCoin.deployed();
    _faucet = await Faucet.deployed();

    await _machoUSD.updateFaucetAddress(_faucet.address);
    await _machoMagic.updateFaucetAddress(_faucet.address);
    await _machoCoin.updateFaucetAddress(_faucet.address);
  });

  describe("Minting ERC20 Tokens", () => {
    before(async () => {
      await _faucet.mintMachoUSD();
      await _faucet.mintMachoMagic({ from: accounts[1] });
    });

    it("Account one should have minted 1000 of MachoUSD", async () => {
      const balanceUSD = await _machoUSD.balanceOf(accounts[0]);
      assert(
        balanceUSD.toString() === "100000",
        "MachoUSD balance is incorrect"
      );
    });

    it("Account two should have minted 1000 of MachoMagic", async () => {
      const balanceMagic = await _machoMagic.balanceOf(accounts[1]);
      assert(
        balanceMagic.toString() === "1000000000000000000000",
        "MachoMagic balance is incorrect"
      );
    });
  });

  describe("Minting ERC1155 Tokens", () => {
    before(async () => {
      await _machoCoin.createToken("hello", 1);
      await _machoCoin.createToken("hello", 2);
      await _faucet.mintMachoCoin(1);
      await _faucet.mintMachoCoin(2, { from: accounts[1] });
    });

    it("Account one should have minted 1000 of MachoCoin token id 1", async () => {
      const token1Balance = await _machoCoin.balanceOf(accounts[0], 1);
      assert(
        token1Balance.toString() === "1000",
        "Token 1 balance is incorrect"
      );
    });

    it("Account two should have minted 1000 of MachoCoin token id 2", async () => {
      const token2Balance = await _machoCoin.balanceOf(accounts[1], 2);
      assert(
        token2Balance.toString() === "1000",
        "Token 2 balance is incorrect"
      );
    });
  });
});
