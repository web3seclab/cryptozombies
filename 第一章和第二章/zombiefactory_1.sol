// SPDX-License-Identifier: MIT
pragma solidity >=0.4.16 <0.9.0;

contract ZombieFactory {
    // 建立事件，事件的参数通常不以下划线(_)开头
    event NewZombie(uint zombieId, string name, uint dna);

    // 在Solidity中， uint 实际上是 uint256代名词，一个256位的无符号整数。
    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits; // 10的16次方

    // 结构体
    struct Zombie {
        string name;
        uint dna;
    }

    // 动态数组，长度不固定，可以动态添加元素
    // 类型[] 修饰符 变量名
    Zombie[] public zombies;


    /**
        internal（内部）某个合约继承自其父合约，这个合约即可以访问父合约中定义的“内部”函数。
        external（外部）函数只能在合约之外调用 - 它们不能被合约内的其他函数调用
     */


    // 习惯上函数里的变量都是以(_)开头，私有函数的名字用(_)开头 (但不是硬性规定)
    function _createZombie(string _name, uint _dna) private {
        /*
            array.push() 在数组的 尾部 加入新元素
            Zombie xx = Zombie("zhangsan", 23);
            zombies.push(xx)
            两步并一步，用一行代码更简洁: zombies.push(Zombie("zhangsan", 23))
         */
        // zombies.push(Zombie(_name, _dna));
        uint id = zombies.push(Zombie(_name, _dna)) - 1;
        // 触发事件，通知app
        NewZombie(id, _name, _dna);
    }

    function _generateRandomDna(string _str) private view returns (uint) {
        /*
        把函数定义为 view ，意味着它只能读取数据不能更改数据
             定义为 pure ，意味着这个函数甚至都不读取应用里的状态 — 它的返回值完全取决于它的输入参数

             注意：如果一个 view 函数在另一个函数的内部被调用，
                    而调用函数与 view 函数的不属于同一个合约，也会产生调用成本。
                    这是因为如果主调函数在以太坊创建了一个事务，它仍然需要逐个节点去验证。
                    所以标记为 view 的函数只有在外部调用时才是免费的。
         */
        // Ethereum 内部有一个散列函数keccak256，它用了SHA3版本。
        uint rand = uint(keccak256(_str)); //散列函数就是把一个字符串转换为一个256位的16进制数字。
        return rand % dnaModulus; // 取模 / 求余: x % y (例如, 13 % 5 余 3, 因为13除以5，余3)
    }

    // 这是公共函数，所以函数名称前面不要有下划线_
    function createRandomZombie(string _name) public {
        uint randDna = _generateRandomDna(_name);
        _createZombie(_name, randDna);
    }
}
