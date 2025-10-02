// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IResponder {
    function respond(bytes calldata trapData) external returns (bool success);
}

contract DroseraResponder is IResponder, Ownable {
    using SafeERC20 for IERC20;
    
    address public operator;
    address public immutable safeVault;
    
    event OperatorUpdated(address indexed newOperator);
    event Responded(
        bytes trapData, 
        bool success, 
        string action, 
        address token, 
        address target, 
        uint256 amount
    );
    
    error NotOperator();
    error InvalidTrapData();
    
    constructor(address _safeVault) {
        require(_safeVault != address(0), "Safe vault required");
        safeVault = _safeVault;
    }
    
    function setOperator(address _operator) external onlyOwner {
        operator = _operator;
        emit OperatorUpdated(_operator);
    }
    
    modifier onlyOperator() {
        if (msg.sender != operator) revert NotOperator();
        _;
    }
    
    // action types:
    // 0x01 => revoke approval (token, spender)
    // 0x02 => transfer token from `from` to safeVault (token, from, amount)  [requires allowance]
    function respond(bytes calldata trapData) external override onlyOperator returns (bool success) {
        if (trapData.length < 1) revert InvalidTrapData();
        
        uint8 actionType = uint8(trapData[0]);
        
        if (actionType == 0x01) {
            (address token, address spender) = abi.decode(trapData[1:], (address, address));
            IERC20(token).safeApprove(spender, 0);
            success = true;
            emit Responded(trapData, success, "REVOKE_APPROVAL", token, spender, 0);
        } else if (actionType == 0x02) {
            (address token, address from, uint256 amount) = abi.decode(trapData[1:], (address, address, uint256));
            IERC20(token).safeTransferFrom(from, safeVault, amount);
            success = true;
            emit Responded(trapData, success, "TRANSFER_TO_SAFE", token, from, amount);
        } else {
            revert InvalidTrapData();
        }
    }
}
