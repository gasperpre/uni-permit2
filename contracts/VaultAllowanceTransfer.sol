// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {IAllowanceTransfer} from "./interfaces/IAllowanceTransfer.sol";
import {VaultCore} from "./VaultCore.sol";

contract VaultAllowanceTransfer is VaultCore {
    constructor(address _permit) VaultCore(_permit)  {
    }
    
    /// @notice Deposit ERC20 token by increasing
    /// allowances with permit
    function deposit(
        uint160 _amount,
        IAllowanceTransfer.PermitSingle calldata _permit,
        bytes calldata _signature
    ) external {
        _increaseUserBalance(msg.sender, _permit.details.token, _amount);

        // 1. Set allowance using permit
        PERMIT2.permit(
            // Owner of the tokens and signer of the message.
            msg.sender,
            // The permit message.
            _permit,
            // The packed signature that was the result of signing
            // the EIP712 hash of `_permit`.
            _signature
        );

        // 2. Transfer the tokens
        PERMIT2.transferFrom(
            msg.sender,
            address(this),
            _amount,
            _permit.details.token
        );
    }

    /// @notice Deposit ERC20 token that already has allowance
    function depositAllowed(
        uint160 _amount,
        address _token
    ) external {
        _increaseUserBalance(msg.sender, _token, _amount);

        PERMIT2.transferFrom(
            msg.sender,
            address(this),
            _amount,
            _token
        );
    }

    /// @notice Deposit multiple ERC20 tokens by increasing
    /// allowances with permit
    function depositBatch(
        uint160 _amount,
        IAllowanceTransfer.PermitBatch calldata _permit,
        bytes calldata _signature
    ) external {

        uint256 len = _permit.details.length;

        IAllowanceTransfer.AllowanceTransferDetails[] memory details = new IAllowanceTransfer.AllowanceTransferDetails[](len);

        for(uint256 i = 0; i < len;){
            address token = _permit.details[i].token;

            details[i] = IAllowanceTransfer.AllowanceTransferDetails({
                from: msg.sender,
                to: address(this),
                amount: _amount,
                token: token
            });

            _increaseUserBalance(msg.sender, token, _amount);

            unchecked {
                ++i;
            }
        }
        
        // 1. Set allowance using permit
        PERMIT2.permit(
            // Owner of the tokens and signer of the message.
            msg.sender,
            // The permit message.
            _permit,
            // The packed signature that was the result of signing
            // the EIP712 hash of `_permit`.
            _signature
        );

        // 2. Transfer the tokens
        PERMIT2.transferFrom(
            details
        );

    }

    /// @notice Deposit ERC20 tokens that already have allowance
    function depositBatchAllowed(
        uint160 _amount,
        address[] calldata _tokens
    ) external {
        uint256 len = _tokens.length;

        IAllowanceTransfer.AllowanceTransferDetails[] memory details = new IAllowanceTransfer.AllowanceTransferDetails[](len);

        for(uint256 i = 0; i < len;){
            address token = _tokens[i];

            details[i] = IAllowanceTransfer.AllowanceTransferDetails({
                from: msg.sender,
                to: address(this),
                amount: _amount,
                token: token
            });

            _increaseUserBalance(msg.sender, token, _amount);

            unchecked {
                ++i;
            }
        }

        PERMIT2.transferFrom(
            details
        );
    }
}
