// Decompiled by library.dedaub.com
// 2025.08.21 13:29 UTC
// Compiled using the solidity compiler version 0.8.28


// Data structures and variables inferred from the use of storage instructions
mapping (uint256 => uint256) _receive; // STORAGE[0x0]
mapping (address => bytes32) mapping_1; // STORAGE[0x1]
mapping (uint256 => address) mapping_2; // STORAGE[0x2]
uint256 stor_3; // STORAGE[0x3]
bool _store; // STORAGE[0x4] bytes 0 to 0


// Events
AccessGranted(address);

function _SafeAdd(uint256 varg0, uint256 varg1) private { 
    require(varg0 <= varg0 + varg1, Panic(17)); // arithmetic overflow or underflow
    return varg0 + varg1;
}

function _SafeMul(uint256 varg0, uint256 varg1) private { 
    require(!varg0 | (varg1 == varg0 * varg1 / varg0), Panic(17)); // arithmetic overflow or underflow
    return varg0 * varg1;
}

function _SafeSub(uint256 varg0, uint256 varg1) private { 
    require(varg0 - varg1 <= varg0, Panic(17)); // arithmetic overflow or underflow
    return varg0 - varg1;
}

function getAccess(uint256 _id) public nonPayable { 
    require(4 + (msg.data.length - 4) - 4 >= 32);
    v0 = 0x525('status');
    require(_receive[v0] - 0, Locked());
    require(1000, Panic(18)); // division by zero
    MEM[64] = 32 + MEM[64] + 32 + 20 + 6;
    require(10 ** 6, Panic(18)); // division by zero
    v1 = v2 = _id == keccak256(block.timestamp / 1000, msg.sender, 'access') % 10 ** 6;
    if (_id != keccak256(block.timestamp / 1000, msg.sender, 'access') % 10 ** 6) {
        v1 = uint256(_id ^ 0x42) == _id ^ 0x42;
    }
    if (v1) {
        v3 = 0x525('admin');
        mapping_1[msg.sender] = v3;
        emit AccessGranted(msg.sender);
    }
}

function 0x3a279611(uint256 varg0) public nonPayable { 
    require(4 + (msg.data.length - 4) - 4 >= 32);
    require(varg0 <= uint64.max);
    require(4 + varg0 + 31 < 4 + (msg.data.length - 4));
    require(varg0.length <= uint64.max);
    require(varg0.data + (varg0.length << 5) <= 4 + (msg.data.length - 4));
    if (varg0.length == 4) {
        require(2 < varg0.length, Panic(50)); // access an out-of-bounds or negative index of bytesN array or slice
        require(1 < varg0.length, Panic(50)); // access an out-of-bounds or negative index of bytesN array or slice
        require(0 < varg0.length, Panic(50)); // access an out-of-bounds or negative index of bytesN array or slice
        v0 = _SafeAdd(varg0[0], varg0[1]);
        v1 = v2 = v0 == varg0[2];
        if (v2) {
            require(3 < varg0.length, Panic(50)); // access an out-of-bounds or negative index of bytesN array or slice
            require(2 < varg0.length, Panic(50)); // access an out-of-bounds or negative index of bytesN array or slice
            v3 = _SafeMul(varg0[2], 2);
            v1 = v4 = v3 == varg0[3];
        }
    } else {
        v1 = v5 = 0;
    }
    return bool(v1);
}

function getHint() public nonPayable { 
    return 'the_drain_function_is_hidden';
}

function 0x498a2031(bytes varg0) public nonPayable { 
    require(4 + (msg.data.length - 4) - 4 >= 32);
    require(varg0 <= uint64.max);
    require(4 + varg0 + 31 < 4 + (msg.data.length - 4));
    require(varg0.length <= uint64.max);
    require(varg0.data + varg0.length <= 4 + (msg.data.length - 4));
    require(mapping_1[msg.sender] - 0, NoAccess());
    v0 = 0x525('admin');
    v1 = v2 = mapping_1[msg.sender] == v0;
    if (mapping_1[msg.sender] != v0) {
        v3 = 0x525('owner');
        v1 = mapping_1[msg.sender] == v3;
    }
    require(v1);
    CALLDATACOPY(v4.data, varg0.data, varg0.length);
    MEM[v4.data + varg0.length] = 0;
    v5, /* uint256 */ v6, /* uint256 */ v7 = address(this).call(v4.data).gas(msg.gas);
    if (RETURNDATASIZE() == 0) {
        v8 = v9 = 96;
    } else {
        v8 = v10 = new bytes[](RETURNDATASIZE());
        RETURNDATACOPY(v10.data, 0, RETURNDATASIZE());
    }
    require(v5, ExecutionFailed());
    v11 = new uint256[](MEM[v8]);
    MCOPY(v11.data, v8 + 32, MEM[v8]);
    MEM[v11.data + MEM[v8]] = 0;
    return v11;
}

function decode(uint256 id_) public nonPayable { 
    require(4 + (msg.data.length - 4) - 4 >= 32);
    require(32 <= uint64.max, Panic(65)); // failed memory allocation (too much memory)
    v0 = new bytes[](32);
    if (32) {
        CALLDATACOPY(v0.data, msg.data.length, 32);
    }
    v1 = v2 = 0;
    while (v1 < 32) {
        v3 = _SafeSub(31, v1);
        v4 = _SafeMul(8, v3);
        require(v1 < v0.length, Panic(50)); // access an out-of-bounds or negative index of bytesN array or slice
        MEM8[32 + v1 + v0] = (byte(bytes1(id_ >> v4 << 248), 0x0)) & 0xFF;
        v1 += 1;
    }
    v5 = new bytes[](v0.length);
    MCOPY(v5.data, v0.data, v0.length);
    v5[32][v0.length] = 0;
    return v5;
}

function retrieve(string _id) public nonPayable { 
    require(4 + (msg.data.length - 4) - 4 >= 32);
    require(_id <= uint64.max);
    require(4 + _id + 31 < 4 + (msg.data.length - 4));
    require(_id.length <= uint64.max);
    require(_id.data + _id.length <= 4 + (msg.data.length - 4));
    v0 = new bytes[](_id.length);
    CALLDATACOPY(v0.data, _id.data, _id.length);
    v0[_id.length] = 0;
    v1 = 0x525(v0);
    return _receive[v1];
}

function scramble(uint256 fee) public nonPayable { 
    require(4 + (msg.data.length - 4) - 4 >= 32);
    return keccak256(fee, 0x651490e7365d8aab49e88aec6ae6efea33c016d3f8f2b6049c60c23c39d9e3ed, block.timestamp) ^ fee;
}

function store(string str, uint256 i) public payable { 
    require(4 + (msg.data.length - 4) - 4 >= 64);
    require(str <= uint64.max);
    require(4 + str + 31 < 4 + (msg.data.length - 4));
    require(str.length <= uint64.max);
    require(str.data + str.length <= 4 + (msg.data.length - 4));
    require(_store, NotReady());
    v0 = new bytes[](str.length);
    CALLDATACOPY(v0.data, str.data, str.length);
    v0[str.length] = 0;
    v1 = 0x525(v0);
    _receive[v1] = i;
    mapping_1[msg.sender] = v1;
    mapping_2[stor_3] = msg.sender;
    require(stor_3 - uint256.max, Panic(17)); // arithmetic overflow or underflow
    stor_3 = stor_3 + 1;
    emit 0xb44a4099a1a4710e3d84492d3ab62eec832c496798a031e7a66d0d0e89cdbff(v1, i);
}

function 0xb70b232d() public nonPayable { 
    v0 = 0x525('owner');
    v1 = v2 = msg.sender != address(_receive[v0]);
    if (msg.sender != address(_receive[v0])) {
        v3 = 0x525('admin');
        v1 = mapping_1[msg.sender] != v3;
    }
    require(!v1, Unauthorized());
    v4 = 0x525('balance');
    _receive[v4] = 0;
    v5 = 0x525('status');
    _receive[v5] = 0;
    emit 0xf25030dea1ced040053b39f74d7a42dd30b2ff8a6c4206fa98f9fceb666cab08(msg.sender, this.balance);
    v6, /* uint256 */ v7 = msg.sender.call().value(this.balance).gas(msg.gas);
    if (RETURNDATASIZE() != 0) {
        v8 = new bytes[](RETURNDATASIZE());
        RETURNDATACOPY(v8.data, 0, RETURNDATASIZE());
    }
    require(v6, TransferFailed());
}

function 0xcffd46dc(uint256 varg0) public nonPayable { 
    require(4 + (msg.data.length - 4) - 4 >= 32);
    if (!(varg0 - keccak256('drain', msg.sender, block.number))) {
        v0 = 0x525(0x676f64);
        mapping_1[msg.sender] = v0;
    }
}

function 0x525(bytes varg0) private { 
    v0 = new uint256[](v0.data + varg0.length + 32 - MEM[64] - 32);
    MCOPY(v0.data, varg0.data, varg0.length);
    MEM[v0.data + varg0.length] = 0;
    MEM[v0.data + varg0.length] = 0x651490e7365d8aab49e88aec6ae6efea33c016d3f8f2b6049c60c23c39d9e3ed;
    MEM[64] = v0.data + varg0.length + 32;
    v1 = v0.length;
    v2 = v0.data;
    return keccak256(v0);
}

function receive() public payable { 
    v0 = 0x525('balance');
    v1 = _SafeAdd(_receive[v0], msg.value);
    _receive[v0] = v1;
}

// Note: The function selector is not present in the original solidity code.
// However, we display it for the sake of completeness.

function __function_selector__( function_selector) public payable { 
    MEM[64] = 128;
    if (msg.data.length < 4) {
        if (!msg.data.length) {
            receive();
        }
    } else if (0x64cc7327 > function_selector >> 224) {
        if (0x2fc82012 == function_selector >> 224) {
            getAccess(uint256);
        } else if (0x3a279611 == function_selector >> 224) {
            0x3a279611();
        } else if (0x41225071 == function_selector >> 224) {
            getHint();
        } else if (0x498a2031 == function_selector >> 224) {
            0x498a2031();
        } else if (0x61a76900 == function_selector >> 224) {
            decode(uint256);
        }
    } else if (0x64cc7327 == function_selector >> 224) {
        retrieve(string);
    } else if (0x6603891c == function_selector >> 224) {
        scramble(uint256);
    } else if (0x7408a1d7 == function_selector >> 224) {
        store(string,uint256);
    } else if (0xb70b232d == function_selector >> 224) {
        0xb70b232d();
    } else if (0xcffd46dc == function_selector >> 224) {
        0xcffd46dc();
    }
    if (!(msg.data.length - 4)) {
        v0 = v1 = bytes4(function_selector);
        if (msg.data.length < 4) {
            v0 = v1 & 0xffffffff00000000000000000000000000000000000000000000000000000000 << (4 - msg.data.length << 3);
        }
        if (!(bytes4(v0) - bytes4(0xb5d09fae7b7af1adf48400132f74ac6d1d5d2e965dfd4f7405cdb9262d87938f))) {
            v2 = 0x525('status');
            require(_receive[v2] - 0, Locked());
            v3 = 0x525('status');
            _receive[v3] = 0;
            emit 0xf25030dea1ced040053b39f74d7a42dd30b2ff8a6c4206fa98f9fceb666cab08(msg.sender, this.balance);
            v4, /* uint256 */ v5 = msg.sender.call().value(this.balance).gas(msg.gas);
            if (RETURNDATASIZE() != 0) {
                v6 = new bytes[](RETURNDATASIZE());
                v5 = v6.data;
                RETURNDATACOPY(v5, 0, RETURNDATASIZE());
            }
            require(v4, TransferFailed());
        }
    }
}
