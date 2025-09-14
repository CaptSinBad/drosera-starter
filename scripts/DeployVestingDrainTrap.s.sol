// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../contracts/traps/VestingDrainTrap.sol";

contract DeployVestingDrainTrap is Script {
    function run() external {
        vm.startBroadcast();

        VestingDrainTrap trap = new VestingDrainTrap();
        console.log("VestingDrainTrap deployed at:", address(trap));

        vm.stopBroadcast();
    }
}
