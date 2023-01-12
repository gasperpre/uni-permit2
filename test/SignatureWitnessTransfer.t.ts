import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { constants, utils } from "ethers";
import { 
    SignatureTransfer, 
    PermitTransferFrom, 
    PERMIT2_ADDRESS, 
    Witness
} from "@uniswap/permit2-sdk";


describe("VaultSignautureWitnessTransfer", function () {
  
  async function loadContracts() {
    const permit2 = await ethers.getContractAt("IPermit2", PERMIT2_ADDRESS);

    const Vault = await ethers.getContractFactory("VaultSignatureWitnessTransfer");
    const vault = await Vault.deploy(PERMIT2_ADDRESS);

    const [account] = await ethers.getSigners();

    return { vault, permit2, account };
  }
  
  async function deployERC20() {
    const ERC20 = await ethers.getContractFactory("ERC20Mock");
    const erc20 = await ERC20.deploy("ERC20Mock", "EM");
    return erc20;
  }

  describe("SignatureWitnessTransfer", function () {
    it("Should deposit", async function () {
        const { vault } = await loadFixture(loadContracts);
        const erc20 = await deployERC20();
        const [owner, user, caller] = await ethers.getSigners();

        const amount = 1000;

        await erc20.mint(owner.address, amount);
        await erc20.connect(owner).approve(PERMIT2_ADDRESS, constants.MaxUint256); // approve max

        const permit: PermitTransferFrom = {
            permitted: {
                token: erc20.address,
                amount: amount
            },
            spender: vault.address,
            nonce: 11,
            deadline: constants.MaxUint256
        };

        const witness: Witness = {
            witnessTypeName: 'Witness',
            witnessType: { Witness: [{ name: 'user', type: 'address' }] },
            witness: { user: user.address },
          }
        const { domain, types, values } = SignatureTransfer.getPermitData(permit, PERMIT2_ADDRESS, 1, witness);
        let signature = await owner._signTypedData(domain, types, values);

        await vault.connect(caller).deposit(amount, erc20.address, owner.address, user.address, permit, signature);
        expect(await vault.tokenBalancesByUser(user.address, erc20.address), amount);
        expect(await erc20.balanceOf(owner.address), 0);
        expect(await erc20.balanceOf(vault.address), amount);
    })

    it("Should not reuse permit", async function () {
        const { vault } = await loadFixture(loadContracts);
        const erc20 = await deployERC20();
        const [owner, user, caller] = await ethers.getSigners();

        const amount = 1000;

        await erc20.mint(owner.address, amount);
        await erc20.connect(owner).approve(PERMIT2_ADDRESS, constants.MaxUint256); // approve max

        const permit: PermitTransferFrom = {
            permitted: {
                token: erc20.address,
                amount: amount
            },
            spender: vault.address,
            nonce: 12,
            deadline: constants.MaxUint256
        };

        const witness: Witness = {
            witnessTypeName: 'Witness',
            witnessType: { Witness: [{ name: 'user', type: 'address' }] },
            witness: { user: user.address },
          }
        const { domain, types, values } = SignatureTransfer.getPermitData(permit, PERMIT2_ADDRESS, 1, witness);
        let signature = await owner._signTypedData(domain, types, values);

        await vault.connect(caller).deposit(amount, erc20.address, owner.address, user.address, permit, signature);
        await expect(vault.connect(caller).deposit(amount, erc20.address, owner.address, user.address, permit, signature)).to.be.reverted;
    })

    it("Should not allow changing user", async function () {
        const { vault } = await loadFixture(loadContracts);
        const [owner, user, caller] = await ethers.getSigners();
        const erc20 = await deployERC20();

        const amount = 1000;

        await erc20.mint(owner.address, amount);
        await erc20.connect(owner).approve(PERMIT2_ADDRESS, constants.MaxUint256); // approve max

        const permit: PermitTransferFrom = {
            permitted: {
                token: erc20.address,
                amount: amount
            },
            spender: vault.address,
            nonce: 13,
            deadline: constants.MaxUint256
        };

        const witness: Witness = {
            witnessTypeName: 'Witness',
            witnessType: { Witness: [{ name: 'user', type: 'address' }] },
            witness: { user: user.address },
          }

        const { domain, types, values } = SignatureTransfer.getPermitData(permit, PERMIT2_ADDRESS, 1, witness);
        let signature = await owner._signTypedData(domain, types, values);

        await expect(vault.connect(caller).deposit(amount, erc20.address, owner.address, caller.address, permit, signature)).to.be.reverted;
    })
  })
});
