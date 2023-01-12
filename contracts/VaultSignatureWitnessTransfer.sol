// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {ISignatureTransfer} from "./interfaces/ISignatureTransfer.sol";
import {VaultCore} from "./VaultCore.sol";

contract VaultSignatureWitnessTransfer is VaultCore {

    struct Witness {
        address user;
    }

    string private constant WITNESS_TYPE_STRING = "Witness witness)TokenPermissions(address token,uint256 amount)Witness(address user)";

    bytes32 private WITNESS_TYPEHASH = keccak256("Witness(address user)");

    constructor(address _permit) VaultCore(_permit)  {
    }


    function deposit(
        uint256 _amount,
        address _token,
        address _owner,
        address _user,
        ISignatureTransfer.PermitTransferFrom calldata _permit,
        bytes calldata _signature
    ) external {
        _increaseUserBalance(_user, _token, _amount);

        PERMIT2.permitWitnessTransferFrom(
            _permit,
            ISignatureTransfer.SignatureTransferDetails({
                to: address(this),
                requestedAmount: _amount
            }),
            _owner,
            // witness
            keccak256(abi.encode(WITNESS_TYPEHASH,Witness(_user))),
            // witnessTypeString,
            WITNESS_TYPE_STRING,
            _signature
        );
    }

}
