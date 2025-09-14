// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/traps/FreshRecipientTrap.sol";

contract MockToken {
    mapping(address => uint256) private _bal;
    function setBalance(address who, uint256 v) external { _bal[who] = v; }
    function balanceOf(address who) external view returns (uint256) { return _bal[who]; }
}

contract FreshRecipientTrapTest is Test {
    MockToken token;
    address recipient = address(0xF00D);
    FreshRecipientTrap trap;

    function setUp() public {
        token = new MockToken();
        // absFloor = 10_000 minimal first large transfer
        trap = new FreshRecipientTrap(address(token), recipient, 10_000);
    }

    function test_no_trigger_if_not_fresh() public {
        // recipient had prior balance
        token.setBalance(recipient, 1_000);
        bytes memory prev = trap.collect();

        token.setBalance(recipient, 20_000); // gained, but not fresh
        bytes memory cur = trap.collect();

        bytes;
        history[0] = cur;
        history[1] = prev;

        (bool fired, ) = trap.shouldRespond(history);
        assertFalse(fired);
    }

    function test_trigger_on_fresh_large_incoming() public {
        // recipient was fresh (0)
        token.setBalance(recipient, 0);
        bytes memory prev = trap.collect();

        token.setBalance(recipient, 50_000); // large first balance
        bytes memory cur = trap.collect();

        bytes;
        history[0] = cur;
        history[1] = prev;

        (bool fired, bytes memory payload) = trap.shouldRespond(history);
        assertTrue(fired);

        (uint256 p, uint256 c, uint256 delta) = abi.decode(payload, (uint256, uint256, uint256));
        assertEq(p, 0);
        assertEq(c, 50_000);
        assertEq(delta, 50_000);
    }
}

