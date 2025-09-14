// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../contracts/traps/OwnerChangeTrap.sol";

contract DeployOwnerChangeTrap is Script {
    function run() external {
        vm.startBroadcast();

        OwnerChangeTrap trap = new OwnerChangeTrap();
        console.log("OwnerChangeTrap deployed at:", address(trap));

        vm.stopBroadcast();
    }
}
