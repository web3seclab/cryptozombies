// SPDX-License-Identifier: MIT
pragma solidity >=0.4.16 <0.9.0;

// 定义一个叫 僵尸工厂 的合约
contract ZombieFactory {
    // 建立事件，事件的参数通常不以下划线(_)开头
    event NewZombie(uint zombieId, string name, uint dna);

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;

    // 1、定义 僵尸的结构体
    struct Zombie {
        string name;
        uint dna;
    }

    // 2、僵尸类型的列表
    Zombie[] public zombies;


    /**
        数据类型：mapping（映射） 和 address（地址）
     */
    
    // 创建一个叫做 zombieToOwner 的映射。其键是一个uint（我们将根据它的 id 存储和查找僵尸），值为 address。映射属性为public。
    // 通过 DNA编号（id）查找到 地址 （僵尸的所有者）
    mapping(uint => address) public zombieToOwner; 
    // 创建一个名为 ownerZombieCount 的映射，其中键是 address，值是 uint。
    // 通过 地址（僵尸所有者的地址）查找僵尸的数量
    mapping(address => uint) ownerZombieCount;

    // 3、生成僵尸的方法
    function _createZombie(string _name, uint _dna) internal {
        // 这里的id是
        uint id = zombies.push(Zombie(_name, _dna)) - 1;

        zombieToOwner[id] = msg.sender; // 调用者(msg.sender) 赋值给 僵尸拥有者id
        ownerZombieCount[msg.sender]++; // 僵尸拥有者 拥有的 僵尸数量 +1

        // 触发事件，通知app
        NewZombie(id, _name, _dna);
    }

    // 4、生成随机生成DNA的方法
    function _generateRandomDna(string _str) private view returns (uint) {
        uint rand = uint(keccak256(_str)); // 这样可以取得16位数字
        return rand % dnaModulus;
    }

    // 5、使用 “创建僵尸的方法” 和 “生成随机dna的方法” 来生成随机僵尸
    function createRandomZombie(string _name) public {
        // Solidity并不支持原生的字符串比较, 只能通过比较两字符串的 keccak256 哈希值来进行判断
        // require 来确保这个函数只有在每个用户第一次调用它的时候执行，用以创建初始僵尸
        require(ownerZombieCount[msg.sender] == 0);
        uint randDna = _generateRandomDna(_name);
        _createZombie(_name, randDna);
    }
}
