// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/traps/LPReserveTrap.sol";

contract MockPair {
    uint112 private r0;
    uint112 private r1;
    constructor(uint112 _r0, uint112 _r1) { r0 = _r0; r1 = _r1; }
    function setReserves(uint112 _r0, uint112 _r1) external { r0 = _r0; r1 = _r1; }
    function getReserves() external view returns (uint112, uint112, uint32) {
        return (r0, r1, uint32(block.timestamp));
    }
}

contract LPReserveTrapTest is Test {
    MockPair pair;
    LPReserveTrap trap;

    function setUp() public {
        pair = new MockPair(1_000_000, 2_000_000);
        // dropBps = 2000 => 20% drop triggers
        trap = new LPReserveTrap(address(pair), 2000);
    }

    function test_no_trigger_on_small_drop() public {
        bytes memory prev = trap.collect();

        pair.setReserves(900_000, 2_000_000); // -10% on reserve0
        bytes memory cur = trap.collect();

        bytes;
        history[0] = cur;
        history[1] = prev;

        (bool fired, ) = trap.shouldRespond(history);
        assertFalse(fired);
    }

    function test_trigger_on_large_drop_reserve0() public {
        bytes memory prev = trap.collect();

        pair.setReserves(700_000, 2_000_000); // -30% on reserve0
        bytes memory cur = trap.collect();

        bytes;
        history[0] = cur;
        history[1] = prev;

        (bool fired, bytes memory payload) = trap.shouldRespond(history);
        assertTrue(fired);

        (uint8 idx, uint256 p, uint256 c, uint256 bps) = abi.decode(payload, (uint8, uint256, uint256, uint256));
        assertEq(idx, uint8(0));
        assertEq(p, 1_000_000);
        assertEq(c, 700_000);
        assertGt(bps, 0);
    }

    function test_trigger_on_large_drop_reserve1() public {
        bytes memory prev = trap.collect();

        pair.setReserves(1_000_000, 1_400_000); // -30% on reserve1
        bytes memory cur = trap.collect();

        bytes;
        history[0] = cur;
        history[1] = prev;

        (bool fired, bytes memory payload) = trap.shouldRespond(history);
        assertTrue(fired);

        (uint8 idx, uint256 p, uint256 c, uint256 bps) = abi.decode(payload, (uint8, uint256, uint256, uint256));
        assertEq(idx, uint8(1));
        assertEq(p, 2_000_000);
        assertEq(c, 1_400_000);
        assertGt(bps, 0);
    }
}

