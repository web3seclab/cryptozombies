// SPDX-License-Identifier: MIT
pragma solidity >=0.4.16 <0.9.0;

/**
 * @title Ownable
 * @dev Ownable合约有一个所有者地址，并提供基本的授权控制功能，这简化了“用户权限”的实现
 */
contract Ownable {
    address public owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Ownable构造函数将合约的原始“所有者”设置为发送者帐户
     */
    function Ownable() public {
        owner = msg.sender;
    }

    /**
     * @dev 如果被所有者以外的任何帐户调用，则抛出。
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev 允许当前所有者将合同的控制权转移给新所有者。
     * @param newOwner要将所有权转移到的地址。
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}