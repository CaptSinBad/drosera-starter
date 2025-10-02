// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface ITrap {
    function collect() external view returns (bytes memory);
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory);
}

interface IGuardianNoBuyback {
    function isBuybackAllowed() external view returns (bool);
}

/**
 * @title BuybackSettingTrap
 * @notice Monitors GuardianNoBuyback contract for unauthorized buyback setting changes
 * @dev Integrates with Drosera's trap system to detect potential governance attacks
 */
contract BuybackSettingTrap is ITrap, Ownable {
    address public guardian;
    bool public trapActive = true;
    
    /// @notice Structure for collected monitoring data
    struct CollectOutput {
        bool buybacksAllowed;
        uint256 timestamp;
        uint256 blockNumber;
    }
    
    event GuardianUpdated(address indexed oldGuardian, address indexed newGuardian);
    event TrapStatusChanged(bool active);
    event BuybackStateCollected(bool buybacksAllowed, uint256 timestamp, uint256 blockNumber);
    
    error InvalidGuardianAddress();
    error TrapInactive();
    error NoDataProvided();
    
    /**
     * @notice Initialize the trap with a guardian contract address
     * @param _guardian Address of the GuardianNoBuyback contract to monitor
     */
    constructor(address _guardian) {
        if (_guardian == address(0)) revert InvalidGuardianAddress();
        guardian = _guardian;
    }
    
    /**
     * @notice Update the guardian contract being monitored
     * @param _guardian New guardian contract address
     */
    function updateGuardian(address _guardian) external onlyOwner {
        if (_guardian == address(0)) revert InvalidGuardianAddress();
        address oldGuardian = guardian;
        guardian = _guardian;
        emit GuardianUpdated(oldGuardian, _guardian);
    }
    
    /**
     * @notice Enable or disable the trap
     * @param _active True to activate, false to deactivate
     */
    function setTrapActive(bool _active) external onlyOwner {
        trapActive = _active;
        emit TrapStatusChanged(_active);
    }
    
    /**
     * @notice Collect current state from the guardian contract
     * @return Encoded CollectOutput struct with current buyback state
     */
    function collect() external view override returns (bytes memory) {
        if (!trapActive) revert TrapInactive();
        
        bool allowed = IGuardianNoBuyback(guardian).isBuybackAllowed();
        
        CollectOutput memory output = CollectOutput({
            buybacksAllowed: allowed,
            timestamp: block.timestamp,
            blockNumber: block.number
        });
        
        return abi.encode(output);
    }
    
    /**
     * @notice Determine if a response should be triggered based on collected data
     * @param data Array of encoded CollectOutput data from multiple collection points
     * @return shouldTrigger True if response should be triggered
     * @return reason Encoded reason for the trigger
     */
    function shouldRespond(bytes[] calldata data) external pure override returns (bool shouldTrigger, bytes memory reason) {
        if (data.length == 0) revert NoDataProvided();
        
        CollectOutput memory current = abi.decode(data[0], (CollectOutput));
        
        // Trigger response if buybacks are disabled
        if (!current.buybacksAllowed) {
            string memory reasonMsg = string(abi.encodePacked(
                "CRITICAL: Buybacks disabled at block ",
                _uint2str(current.blockNumber),
                " - Potential governance attack or unauthorized access"
            ));
            return (true, abi.encode(reasonMsg));
        }
        
        // Optional: Check for state changes across multiple data points
        if (data.length > 1) {
            CollectOutput memory previous = abi.decode(data[1], (CollectOutput));
            
            // Detect state flip from allowed to disallowed
            if (previous.buybacksAllowed && !current.buybacksAllowed) {
                string memory reasonMsg = string(abi.encodePacked(
                    "ALERT: Buyback state changed from enabled to disabled between blocks ",
                    _uint2str(previous.blockNumber),
                    " and ",
                    _uint2str(current.blockNumber)
                ));
                return (true, abi.encode(reasonMsg));
            }
        }
        
        return (false, bytes(""));
    }
    
    /**
     * @notice Check current buyback status directly
     * @return Current buyback allowed state
     */
    function getCurrentBuybackStatus() external view returns (bool) {
        return IGuardianNoBuyback(guardian).isBuybackAllowed();
    }
    
    /**
     * @dev Internal helper to convert uint to string for error messages
     */
    function _uint2str(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}
