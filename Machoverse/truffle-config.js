const HDWalletProvider = require("@truffle/hdwallet-provider");
const keys = require("./keys.json");

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "5777",
    },
    goerli: {
      provider: () => new HDWalletProvider(keys.KEY, keys.INFURA_URL),
      network_id: "5",
      gas: 5500000,
      gasPrice: 20000000000,
      confirmations: 2,
      timeoutBlocks: 200,
    },
  },

  compilers: {
    solc: {
      version: "0.8.17",
    },
  },
  api_keys: {
    etherscan: keys.ETHERSCAN,
  },
  plugins: ["truffle-plugin-verify"],
};
