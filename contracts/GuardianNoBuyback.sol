// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/access/Ownable.sol";

contract GuardianNoBuyback is Ownable {
    bool public buybacksAllowed = true;
    
    event BuybacksAllowedSet(bool allowed, address setter);
    
    function setBuybacksAllowed(bool allowed) external onlyOwner {
        buybacksAllowed = allowed;
        emit BuybacksAllowedSet(allowed, msg.sender);
    }
    
    function isBuybackAllowed() external view returns (bool) {
        return buybacksAllowed;
    }
}
