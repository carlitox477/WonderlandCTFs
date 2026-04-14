// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {EchoModule} from "../src/EchoModule.sol";
import {Challenge} from "../src/Challenge.sol";
import {DeployerFactory} from "./DeployerFactory.sol";

contract AttackTest is Test {
    EchoModule echoModuleRef;
    Challenge challenge;
    DeployerFactory deployerFactory;

    function setUp() public {
        echoModuleRef = new EchoModule();
        challenge = new Challenge{value: 10 ether}(address(echoModuleRef));
        deployerFactory = new DeployerFactory(address(challenge.VAULT()));

        // Done in setup because this is done in a separate transaction that each test
        deployerFactory.phase1();
    }

    function testExploit() public {     
        deployerFactory.phase2();
        require(challenge.isSolved(), "Challenge not solved");
    }

    // To be able to perform exploit
    receive() external payable {}
}
