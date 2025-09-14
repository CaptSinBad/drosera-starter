// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../contracts/traps/FreshRecipientTrap.sol";

contract DeployFreshRecipientTrap is Script {
    function run() external {
        vm.startBroadcast();

        FreshRecipientTrap trap = new FreshRecipientTrap();
        console.log("FreshRecipientTrap deployed at:", address(trap));

        vm.stopBroadcast();
    }
}
