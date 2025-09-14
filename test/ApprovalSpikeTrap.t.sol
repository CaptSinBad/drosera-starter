// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/traps/ApprovalSpikeTrap.sol";

contract MockERC20Allow {
    mapping(address => mapping(address => uint256)) public allowances;
    function setAllowance(address owner, address spender, uint256 v) external { allowances[owner][spender] = v; }
    function allowance(address owner, address spender) external view returns (uint256) { return allowances[owner][spender]; }
}

contract ApprovalSpikeTrapTest is Test {
    MockERC20Allow token;
    address ownerAddr = address(0xABCD);
    address spenderAddr = address(0xBEEF);
    // trigger if allowance increases >= 1000 bps (10%) or absolute floor reached
    ApprovalSpikeTrap trap;

    function setUp() public {
        token = new MockERC20Allow();
        trap = new ApprovalSpikeTrap(address(token), ownerAddr, spenderAddr, 1000, 500_000);
    }

    function test_no_trigger_on_small_increase() public {
        token.setAllowance(ownerAddr, spenderAddr, 100_000);
        bytes memory prev = trap.collect();

        token.setAllowance(ownerAddr, spenderAddr, 105_000); // +5%
        bytes memory cur = trap.collect();

        bytes;
        history[0] = cur;
        history[1] = prev;

        (bool fired, ) = trap.shouldRespond(history);
        assertFalse(fired);
    }

    function test_trigger_on_large_relative_increase() public {
        token.setAllowance(ownerAddr, spenderAddr, 100_000);
        bytes memory prev = trap.collect();

        token.setAllowance(ownerAddr, spenderAddr, 250_000); // +150%
        bytes memory cur = trap.collect();

        bytes;
        history[0] = cur;
        history[1] = prev;

        (bool fired, bytes memory payload) = trap.shouldRespond(history);
        assertTrue(fired);

        (uint256 p, uint256 c, uint256 bps) = abi.decode(payload, (uint256, uint256, uint256));
        assertEq(p, 100_000);
        assertEq(c, 250_000);
        assertGt(bps, 0);
    }

    function test_trigger_when_prev_zero_and_above_absFloor() public {
        token.setAllowance(ownerAddr, spenderAddr, 0);
        bytes memory prev = trap.collect();

        token.setAllowance(ownerAddr, spenderAddr, 600_000); // above absFloor = 500_000
        bytes memory cur = trap.collect();

        bytes;
        history[0] = cur;
        history[1] = prev;

        (bool fired, bytes memory payload) = trap.shouldRespond(history);
        assertTrue(fired);

        (uint256 p, uint256 c, uint256 bps) = abi.decode(payload, (uint256, uint256, uint256));
        assertEq(p, 0);
        assertEq(c, 600_000);
        assertEq(bps, 10000); // when prev==0, trap encodes 10000 to indicate 100%
    }
}

