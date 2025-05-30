// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {SparkUp} from "../src/SparkUp.sol";

contract SparkUpScript is Script {
    SparkUp public sparkup;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        sparkup = new SparkUp();

        vm.stopBroadcast();
    }
}
