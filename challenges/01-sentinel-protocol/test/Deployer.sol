// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {EvilModule} from "./EvilModule.sol";
import {ISentinelVault} from "../src/interfaces/ISentinelVault.sol";
import {EchoModule} from "../src/EchoModule.sol";

contract Deployer {
    ISentinelVault public sentinelVault;
    address public currentDeployedModule;

    constructor() {}

    function setSentinel(address _sentinelVault) external {
        sentinelVault = ISentinelVault(_sentinelVault);
    }

    function deployAndDestructEchoModule() external returns (address) {
        // require(currentDeployedModule == address(0), "Module already deployed");

        currentDeployedModule = address(new EchoModule());

        // Register in sentinel vault
        sentinelVault.registerModule(currentDeployedModule);

        // Destruct
        EchoModule(currentDeployedModule).decommission();

        return currentDeployedModule;
    }

    function deployEvilModule() external returns (address) {
        // require(currentDeployedModule == address(0), "Module already deployed");
        require(address(sentinelVault) != address(0), "Sentinel vault not set");

        currentDeployedModule = address(new EvilModule(sentinelVault));
        
        return currentDeployedModule;
    }

    function destruct() external{
        // To reset
        // require(currentDeployedModule.code.length == 0, "Module code is not self-destructed yet");
        
        selfdestruct(payable(msg.sender));
    }
    

}