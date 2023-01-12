// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {ISignatureTransfer} from "./interfaces/ISignatureTransfer.sol";
import {VaultCore} from "./VaultCore.sol";

contract VaultSignatureTransfer is VaultCore {

    constructor(address _permit) VaultCore(_permit)  {
    }
    

    /// @notice Deposit ERC20 token withouth increasing 
    /// allowance using permitTransferFrom
    function deposit(
        uint256 _amount,
        ISignatureTransfer.PermitTransferFrom calldata _permit,
        bytes calldata _signature
    ) external {
        _increaseUserBalance(msg.sender, _permit.permitted.token, _amount);

        PERMIT2.permitTransferFrom(
            // The permit message.
            _permit,
            // The transfer recipient and amount.
            ISignatureTransfer.SignatureTransferDetails({
                to: address(this),
                requestedAmount: _amount
            }),
            // Owner of the tokens and signer of the message.
            msg.sender,
            // The packed signature that was the result of signing
            // the EIP712 hash of `_permit`.
            _signature
        );
    }

    /// @notice Deposit multiple ERC20 tokens withouth increasing
    /// allowances using permitTransferFrom
    function depositBatch(
        uint256 _amount,
        ISignatureTransfer.PermitBatchTransferFrom calldata _permit,
        bytes calldata _signature
    ) external {
        uint256 len = _permit.permitted.length;

        ISignatureTransfer.SignatureTransferDetails[] memory details = new ISignatureTransfer.SignatureTransferDetails[](len);

        for(uint256 i = 0; i < len;){
            _increaseUserBalance(msg.sender, _permit.permitted[i].token, _amount);

            details[i].to = address(this);
            details[i].requestedAmount = _amount;

            unchecked {
                ++i;
            }
        }

        PERMIT2.permitTransferFrom(
            // The permit message.
            _permit,
            // The transfer recipients and amounts.
            details,
            // Owner of the tokens and signer of the message.
            msg.sender,
            // The packed signature that was the result of signing
            // the EIP712 hash of `_permit`.
            _signature
        );
    }
}
