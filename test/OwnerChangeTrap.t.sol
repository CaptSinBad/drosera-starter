// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/traps/OwnerChangeTrap.sol";

contract MockOwnable {
    address private _owner;
    constructor(address o) { _owner = o; }
    function owner() external view returns (address) { return _owner; }
    function setOwner(address o) external { _owner = o; }
}

contract OwnerChangeTrapTest is Test {
    MockOwnable subject;
    OwnerChangeTrap trap;

    function setUp() public {
        subject = new MockOwnable(address(0x1111));
        trap = new OwnerChangeTrap(address(subject));
    }

    function test_no_trigger_if_owner_unchanged() public {
        // initial collect
        bytes memory prev = trap.collect();

        // no change
        bytes memory cur = trap.collect();

        bytes;
        history[0] = cur;
        history[1] = prev;

        (bool fired, ) = trap.shouldRespond(history);
        assertFalse(fired);
    }

    function test_trigger_on_owner_change() public {
        bytes memory prev = trap.collect();

        // change owner
        subject.setOwner(address(0x2222));

        bytes memory cur = trap.collect();

        bytes;
        history[0] = cur;
        history[1] = prev;

        (bool fired, bytes memory payload) = trap.shouldRespond(history);
        assertTrue(fired);

        (address prevOwner, address newOwner) = abi.decode(payload, (address, address));
        assertEq(prevOwner, address(0x1111));
        assertEq(newOwner, address(0x2222));
    }
}
