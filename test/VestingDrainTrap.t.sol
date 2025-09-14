// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/traps/VestingDrainTrap.sol";

contract MockToken {
    mapping(address => uint256) private _bal;
    function setBalance(address who, uint256 v) external { _bal[who] = v; }
    function balanceOf(address who) external view returns (uint256) { return _bal[who]; }
}

contract VestingDrainTrapTest is Test {
    MockToken token;
    address vesting;
    VestingDrainTrap trap;

    function setUp() public {
        token = new MockToken();
        vesting = address(0xCAFE);
        // drain threshold 2000 bps = 20%
        trap = new VestingDrainTrap(address(token), vesting, 2000);
    }

    function test_no_trigger_on_small_drain() public {
        token.setBalance(vesting, 1_000_000);
        bytes memory prev = trap.collect();

        token.setBalance(vesting, 900_000); // -10%
        bytes memory cur = trap.collect();

        bytes;
        history[0] = cur;
        history[1] = prev;

        (bool fired, ) = trap.shouldRespond(history);
        assertFalse(fired);
    }

    function test_trigger_on_large_drain() public {
        token.setBalance(vesting, 1_000_000);
        bytes memory prev = trap.collect();

        token.setBalance(vesting, 700_000); // -30%
        bytes memory cur = trap.collect();

        bytes;
        history[0] = cur;
        history[1] = prev;

        (bool fired, bytes memory payload) = trap.shouldRespond(history);
        assertTrue(fired);

        (uint256 prevBal, uint256 curBal, uint256 bps) = abi.decode(payload, (uint256, uint256, uint256));
        assertEq(prevBal, 1_000_000);
        assertEq(curBal, 700_000);
        assertGt(bps, 0);
    }
}

