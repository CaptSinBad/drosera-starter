// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../contracts/traps/ApprovalSpikeTrap.sol";

contract DeployApprovalSpikeTrap is Script {
    function run() external {
        vm.startBroadcast();

        ApprovalSpikeTrap trap = new ApprovalSpikeTrap();
        console.log("ApprovalSpikeTrap deployed at:", address(trap));

        vm.stopBroadcast();
    }
}
