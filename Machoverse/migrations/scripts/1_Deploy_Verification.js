const VerifyBytes = artifacts.require("VerifyBytes");

module.exports = async (deployer) => {
  await deployer.deploy(VerifyBytes);
  console.log("Verification Address", VerifyBytes.address);
};
