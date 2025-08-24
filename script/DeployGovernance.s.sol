// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Script} from "forge-std/Script.sol";
import {SimpleVotingToken} from "../src/GovernanceMRW.sol";

contract DeployScript is Script {
    function run() external {
        vm.startBroadcast();
        new SimpleVotingToken();
        vm.stopBroadcast();
    }
}