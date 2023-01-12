// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IPermit2} from "./interfaces/IPermit2.sol";

contract VaultCore {
    using SafeERC20 for IERC20;
    
    IPermit2 public immutable PERMIT2;

    // account -> token -> balance
    mapping (address => mapping (address => uint256)) public tokenBalancesByUser;

    constructor(address _permit) {
        PERMIT2 = IPermit2(_permit);
    }

    // @notice Increases users deposited token balance by given amount 
    function _increaseUserBalance(
        address _account,
        address _token,
        uint256 _amount
    ) internal {
        tokenBalancesByUser[_account][_token] += _amount;
    }

    // @notice Withdraw ERC20 tokens deposited by the caller.
    function withdrawERC20(address _token, uint256 _amount) external {
        tokenBalancesByUser[msg.sender][_token] -= _amount;
        
        IERC20(_token).safeTransfer(msg.sender, _amount);
    }
}
