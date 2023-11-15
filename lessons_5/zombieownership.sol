pragma solidity ^0.4.19;

import "./zombieattack.sol";
import "./erc721.sol";

// 多继承，用逗号分隔即可
contract ZombieOwnership is ZombieAttack, ERC721 {
    mapping (uint => address) zombieApprovals;

    // 根据地址查找拥有的僵尸数
    function balanceOf(address _owner) public view returns (uint256 _balance) {
        // ownerZombieCount 是在 zombiefactory.sol中的映射
        return ownerZombieCount[_owner];
    }

    // 根据tokenId 查找拥有者
    function ownerOf(uint256 _tokenId) public view returns (address _owner) {
        return zombieToOwner[_tokenId];
    }

    // 转移
    function _transfer(address _from, address _to, uint256 _tokenId) private {
        // ownerZombieCount 是在 zombiefactory.sol中的映射
        ownerZombieCount[_to]++;
        ownerZombieCount[_from]--;
        zombieToOwner[_tokenId] = _to;

        // 触发erc721.sol中的Transfer事件
        Transfer(_from, _to, _tokenId);
    }

    // 注意：这里onlyOwnerOf的参数是_tokenId
    function transfer(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
        _transfer(msg.sender, _to, _tokenId);
    }

    function approve(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
        zombieApprovals[_tokenId] = _to;
        // 触发erc721.sol中的Approval事件
        Approval(msg.sender, _to, _tokenId);
    }

    function takeOwnership(uint256 _tokenId) public {
        require(zombieApprovals[_tokenId] == msg.sender);
        address owner = ownerOf(_tokenId);
        _transfer(owner, msg.sender, _tokenId);
    }
}
