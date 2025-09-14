// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "drosera-contracts/interfaces/ITrap.sol";

interface IERC20Bal { function balanceOf(address) external view returns (uint256); }

contract VestingDrainTrap is ITrap {
    address public immutable token;
    address public immutable vesting;
    uint256 public immutable drainBps; // e.g., 2000 = 20%

    struct CollectOutput { uint256 balance; }

    constructor(address _token, address _vesting, uint256 _drainBps) {
        token = _token; vesting = _vesting; drainBps = _drainBps;
    }

    function collect() external view override returns (bytes memory) {
        uint256 bal = IERC20Bal(token).balanceOf(vesting);
        return abi.encode(CollectOutput({ balance: bal }));
    }

    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        if (data.length < 2) return (false, bytes(""));
        CollectOutput memory cur = abi.decode(data[0], (CollectOutput));
        CollectOutput memory prev = abi.decode(data[1], (CollectOutput));
        if (prev.balance == 0) return (false, bytes(""));
        if (cur.balance >= prev.balance) return (false, bytes(""));
        uint256 delta = prev.balance - cur.balance;
        uint256 bps = (delta * 10000) / prev.balance;
        if (bps >= drainBps) return (true, abi.encode(prev.balance, cur.balance, bps));
        return (false, bytes(""));
    }
}

