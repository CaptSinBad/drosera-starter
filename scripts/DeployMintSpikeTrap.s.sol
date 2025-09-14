// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../contracts/traps/MintSpikeTrap.sol";

contract DeployMintSpikeTrap is Script {
    function run() external {
        vm.startBroadcast();

        MintSpikeTrap trap = new MintSpikeTrap();
        console.log("MintSpikeTrap deployed at:", address(trap));

        vm.stopBroadcast();
    }
}
