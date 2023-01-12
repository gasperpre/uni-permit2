import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import * as dotenv from "dotenv";

dotenv.config({path: __dirname + '/.env'});
const { MAINNET_RPC_URL } = process.env;

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  networks: {
    hardhat: {
      // url: 'http://127.0.0.1:8545',
      forking: {
        enabled: true,
        url: MAINNET_RPC_URL as string,
        blockNumber: 16382910
      },
      chainId: 1
    }
  }
};

export default config;
