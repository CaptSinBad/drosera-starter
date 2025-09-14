// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "drosera-contracts/interfaces/ITrap.sol";

interface IOwnable {
    function owner() external view returns (address);
}

contract OwnerChangeTrap is ITrap {
    address public immutable target;

    struct CollectOutput { address owner; }

    constructor(address _target) { target = _target; }

    function collect() external view override returns (bytes memory) {
        address o = IOwnable(target).owner();
        return abi.encode(CollectOutput({ owner: o }));
    }

    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        if (data.length < 2) return (false, bytes(""));
        CollectOutput memory current = abi.decode(data[0], (CollectOutput));
        CollectOutput memory prev = abi.decode(data[1], (CollectOutput));
        if (current.owner != prev.owner) {
            return (true, abi.encode(prev.owner, current.owner));
        }
        return (false, bytes(""));
    }
}

