// SPDX-License-Identifier: MIT
pragma solidity >=0.4.16 <0.9.0;

import "./zombiefactory_2.sol";

/**
    storage 永久存储在区块链中的变量；
    memory 临时变量，函数调用结束后消失
 */

// 注意这是一个接口interface，不是合约。
// 因为在花括号里面只定义了一个函数，这个函数中没有使用任何其他函数或状态变量，而是直接return。
contract KittyInterface {
    function getKitty(uint256 _id) external view returns (
            bool isGestating,
            bool isReady,
            uint256 cooldownIndex,
            uint256 nextActionAt,
            uint256 siringWithId,
            uint256 birthTime,
            uint256 matronId,
            uint256 sireId,
            uint256 generation,
            uint256 genes
        ); 
}

contract ZombieFeeding is ZombieFactory {
    address ckAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
    KittyInterface kittyContract = KittyInterface(ckAddress);

    function feedAndMultiply(uint _zombieId, uint _targetDna, string _species) public {
        require(msg.sender == zombieToOwner[_zombieId]); // 确保僵尸的拥有权
        Zombie storage myZombie = zombies[_zombieId];

        _targetDna = _targetDna % dnaModulus;
        uint newDna = (myZombie.dna + _targetDna) / 2;

        if (keccak256(_species) == keccak256("kitty")) {
            newDna = newDna - (newDna % 100) + 99; // 例如：5432 % 100 得到 32，然后5432 - 32 + 99 = 5499
        }
        _createZombie("NoName", newDna);
    }

    function feedOnKitty(uint _zombieId, uint _kittyId) public {
        uint kittyDna;
        (, , , , , , , , , kittyDna) = kittyContract.getKitty(_kittyId); // 函数有10个返回值，但是我们只需要最后一个
        feedAndMultiply(_zombieId, kittyDna, "kitty");
    }
}
