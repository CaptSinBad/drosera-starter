// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../contracts/DroseraResponder.sol";

contract DeployDroseraResponder is Script {
    function run() external {
        vm.startBroadcast();

        DroseraResponder responder = new DroseraResponder();
        console.log("DroseraResponder deployed at:", address(responder));

        vm.stopBroadcast();
    }
}
