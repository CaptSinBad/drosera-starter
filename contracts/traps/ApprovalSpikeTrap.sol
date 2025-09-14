// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "drosera-contracts/interfaces/ITrap.sol";

interface IERC20Allow { function allowance(address, address) external view returns (uint256); }

contract ApprovalSpikeTrap is ITrap {
    address public immutable token;
    address public immutable ownerAddr;
    address public immutable spenderAddr;
    uint256 public immutable increaseBps;
    uint256 public immutable absFloor;

    struct CollectOutput { uint256 allowanceValue; }

    constructor(address _token, address _owner, address _spender, uint256 _increaseBps, uint256 _absFloor) {
        token = _token; ownerAddr = _owner; spenderAddr = _spender;
        increaseBps = _increaseBps; absFloor = _absFloor;
    }

    function collect() external view override returns (bytes memory) {
        uint256 a = IERC20Allow(token).allowance(ownerAddr, spenderAddr);
        return abi.encode(CollectOutput({ allowanceValue: a }));
    }

    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        if (data.length < 2) return (false, bytes(""));
        CollectOutput memory cur = abi.decode(data[0], (CollectOutput));
        CollectOutput memory prev = abi.decode(data[1], (CollectOutput));
        if (cur.allowanceValue <= prev.allowanceValue) return (false, bytes(""));
        if (prev.allowanceValue == 0) {
            if (cur.allowanceValue >= absFloor) return (true, abi.encode(prev.allowanceValue, cur.allowanceValue, uint256(10000)));
            return (false, bytes(""));
        }
        uint256 delta = cur.allowanceValue - prev.allowanceValue;
        uint256 bps = (delta * 10000) / prev.allowanceValue;
        if (bps >= increaseBps || cur.allowanceValue >= absFloor) {
            return (true, abi.encode(prev.allowanceValue, cur.allowanceValue, bps));
        }
        return (false, bytes(""));
    }
}

