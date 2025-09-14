// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DaoLpVault is Ownable, Pausable {
    address public token; // underlying ERC20 (LP token)
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event EmergencyWithdraw(address token, address to, uint256 amount);

    constructor(address _token) {
        token = _token;
    }

    function pauseVault() external onlyOwner {
        _pause();
    }
    function unpauseVault() external onlyOwner {
        _unpause();
    }

    function deposit(uint256 amount) external whenNotPaused {
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        emit Deposited(msg.sender, amount);
    }

    function withdraw(uint256 amount) external whenNotPaused {
        IERC20(token).transfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    // emergency withdrawal only by owner (multisig recommended)
    function emergencyWithdraw(address _token, address to, uint256 amount) external onlyOwner {
        IERC20(_token).transfer(to, amount);
        emit EmergencyWithdraw(_token, to, amount);
    }

    function balance() external view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }
}
