// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "drosera-contracts/interfaces/ITrap.sol";

interface IPair { function getReserves() external view returns (uint112, uint112, uint32); }

contract LPReserveTrap is ITrap {
    address public immutable pair;
    uint256 public immutable dropBps;

    struct CollectOutput { uint256 reserve0; uint256 reserve1; }

    constructor(address _pair, uint256 _dropBps) { pair = _pair; dropBps = _dropBps; }

    function collect() external view override returns (bytes memory) {
        (uint112 r0, uint112 r1, ) = IPair(pair).getReserves();
        return abi.encode(CollectOutput({ reserve0: uint256(r0), reserve1: uint256(r1) }));
    }

    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        if (data.length < 2) return (false, bytes(""));
        CollectOutput memory cur = abi.decode(data[0], (CollectOutput));
        CollectOutput memory prev = abi.decode(data[1], (CollectOutput));
        if (prev.reserve0 == 0 || prev.reserve1 == 0) return (false, bytes(""));
        if (cur.reserve0 < prev.reserve0) {
            uint256 d0 = prev.reserve0 - cur.reserve0;
            uint256 bps0 = (d0 * 10000) / prev.reserve0;
            if (bps0 >= dropBps) return (true, abi.encode(uint8(0), prev.reserve0, cur.reserve0, bps0));
        }
        if (cur.reserve1 < prev.reserve1) {
            uint256 d1 = prev.reserve1 - cur.reserve1;
            uint256 bps1 = (d1 * 10000) / prev.reserve1;
            if (bps1 >= dropBps) return (true, abi.encode(uint8(1), prev.reserve1, cur.reserve1, bps1));
        }
        return (false, bytes(""));
    }
}

