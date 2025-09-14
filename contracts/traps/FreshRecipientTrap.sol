// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "drosera-contracts/interfaces/ITrap.sol";

interface IERC20Bal { function balanceOf(address) external view returns (uint256); }

contract FreshRecipientTrap is ITrap {
    address public immutable token;
    address public immutable recipient;
    uint256 public immutable absFloor;

    struct CollectOutput { uint256 balance; }

    constructor(address _token, address _recipient, uint256 _absFloor) {
        token = _token; recipient = _recipient; absFloor = _absFloor;
    }

    function collect() external view override returns (bytes memory) {
        uint256 bal = IERC20Bal(token).balanceOf(recipient);
        return abi.encode(CollectOutput({ balance: bal }));
    }

    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        if (data.length < 2) return (false, bytes(""));
        CollectOutput memory cur = abi.decode(data[0], (CollectOutput));
        CollectOutput memory prev = abi.decode(data[1], (CollectOutput));
        // treat "fresh" as previous.balance == 0
        if (prev.balance != 0) return (false, bytes(""));
        if (cur.balance <= prev.balance) return (false, bytes(""));
        uint256 delta = cur.balance - prev.balance;
        if (delta >= absFloor) return (true, abi.encode(prev.balance, cur.balance, delta));
        return (false, bytes(""));
    }
}

