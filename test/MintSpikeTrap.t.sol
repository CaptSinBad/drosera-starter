// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/traps/MintSpikeTrap.sol";

contract MockToken {
    uint256 private _totalSupply;
    function setTotalSupply(uint256 s) external { _totalSupply = s; }
    function totalSupply() external view returns (uint256) { return _totalSupply; }
}

contract MintSpikeTrapTest is Test {
    MockToken token;
    MintSpikeTrap trap;

    function setUp() public {
        token = new MockToken();
        // threshold 500 bps = 5%
        trap = new MintSpikeTrap(address(token), 500);
    }

    function test_no_trigger_when_small_mint() public {
        token.setTotalSupply(1_000_000);
        bytes memory prev = trap.collect();

        token.setTotalSupply(1_030_000); // +3%
        bytes memory cur = trap.collect();

        bytes;
        history[0] = cur;
        history[1] = prev;

        (bool ok, ) = trap.shouldRespond(history);
        assertFalse(ok);
    }

    function test_trigger_when_large_mint() public {
        token.setTotalSupply(1_000_000);
        bytes memory prev = trap.collect();

        token.setTotalSupply(1_200_000); // +20%
        bytes memory cur = trap.collect();

        bytes;
        history[0] = cur;
        history[1] = prev;

        (bool ok, bytes memory payload) = trap.shouldRespond(history);
        assertTrue(ok);

        (uint256 p, uint256 c, uint256 bps) = abi.decode(payload, (uint256, uint256, uint256));
        assertEq(p, 1_000_000);
        assertEq(c, 1_200_000);
        assertGt(bps, 0);
    }
}

