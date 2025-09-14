// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "drosera-contracts/interfaces/ITrap.sol";

interface IERC20Min { function totalSupply() external view returns (uint256); }

contract MintSpikeTrap is ITrap {
    address public immutable token;
    uint256 public immutable bpsThreshold; // e.g., 500 = 5%

    struct CollectOutput { uint256 totalSupply; }

    constructor(address _token, uint256 _bpsThreshold) {
        token = _token; bpsThreshold = _bpsThreshold;
    }

    function collect() external view override returns (bytes memory) {
        uint256 s = IERC20Min(token).totalSupply();
        return abi.encode(CollectOutput({ totalSupply: s }));
    }

    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        if (data.length < 2) return (false, bytes(""));
        CollectOutput memory cur = abi.decode(data[0], (CollectOutput));
        CollectOutput memory prev = abi.decode(data[1], (CollectOutput));
        if (prev.totalSupply == 0) return (false, bytes(""));
        if (cur.totalSupply <= prev.totalSupply) return (false, bytes(""));
        uint256 delta = cur.totalSupply - prev.totalSupply;
        uint256 bps = (delta * 10000) / prev.totalSupply;
        if (bps >= bpsThreshold) return (true, abi.encode(prev.totalSupply, cur.totalSupply, bps));
        return (false, bytes(""));
    }
}

