import { ethers } from "hardhat";
import { 
    PERMIT2_ADDRESS 
} from "@uniswap/permit2-sdk";

async function main() {
  const VaultAllowanceTransfer = await ethers.getContractFactory("VaultAllowanceTransfer");
  const vaultAllowanceTransfer = await VaultAllowanceTransfer.deploy(PERMIT2_ADDRESS);
  await vaultAllowanceTransfer.deployed();

  const VaultSignatureTransfer = await ethers.getContractFactory("VaultSignatureTransfer");
  const vaultSignatureTransfer = await VaultSignatureTransfer.deploy(PERMIT2_ADDRESS);
  await vaultSignatureTransfer.deployed();

  console.log(`Deployed`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
