require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.26",
    settings: {
      optimizer: { enabled: true, runs: 200 }
    }
  },
  networks: {
    arbitrum: {
      url: process.env.RPC_PROVIDER || "https://arb1.arbitrum.io/rpc",
      accounts: [process.env.DEPLOYER_PRIVATE_KEY],
      chainId: 42161,
    }
  },
  etherscan: {
    apiKey: {
      arbitrumOne: process.env.ARBISCAN_API_KEY || ""
    }
  }
};
