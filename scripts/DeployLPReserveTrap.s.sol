// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../contracts/traps/LPReserveTrap.sol";

contract DeployLPReserveTrap is Script {
    function run() external {
        vm.startBroadcast();

        LPReserveTrap trap = new LPReserveTrap();
        console.log("LPReserveTrap deployed at:", address(trap));

        vm.stopBroadcast();
    }
}
