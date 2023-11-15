# 第1章: 可支付

可见性修饰符

`private` 意味着它只能被合约内部调用； 

`internal` 就像 `private` 但是也能被继承的合约调用；

 `external` 只能从合约外部调用；

 `public` 可以在任何地方调用，不管是内部还是外部。



状态修饰符

`view` 告诉我们运行这个函数不会更改和保存任何数据； 

`pure` 告诉我们这个函数不但不会往区块链写数据，它甚至不从区块链读取数据。

这两种在被从合约外部调用的时候都不花费任何gas（但是它们在被内部其他函数调用的时候将会耗费gas）。



有了自定义的 `modifiers`，例如在第三课学习的: `onlyOwner` 和 `aboveLevel`。 对于这些修饰符我们可以自定义其对函数的约束逻辑。

这些修饰符可以同时作用于一个函数定义上：

```
function test() external view onlyOwner anotherModifier { /* ... */ }
```

## `payable` 修饰符

`payable` 方法是让 Solidity 和以太坊变得如此酷的一部分 —— 它们是一种可以接收以太的特殊函数。

先放一下。当你在调用一个普通网站服务器上的API函数的时候，你无法用你的函数传送美元——你也不能传送比特币。

但是在以太坊中， 因为钱 (_以太_), 数据 (*事务负载*)， 以及合约代码本身都存在于以太坊。你可以在同时调用函数 **并**付钱给另外一个合约。

这就允许出现很多有趣的逻辑， 比如向一个合约要求支付一定的钱来运行一个函数。

## 来看个例子

```solidity
contract OnlineStore {
  function buySomething() external payable {
    // 检查以确定0.001以太发送出去来运行函数:
    require(msg.value == 0.001 ether);
    // 如果为真，一些用来向函数调用者发送数字内容的逻辑
    transferThing(msg.sender);
  }
}
```

在这里，`msg.value` 是一种可以查看向合约发送了多少以太的方法，另外 `ether` 是一个內建单元。

这里发生的事是，一些人会从 web3.js 调用这个函数 (从DApp的前端)， 像这样 :

```
// 假设 `OnlineStore` 在以太坊上指向你的合约:
OnlineStore.buySomething().send(from: web3.eth.defaultAccount, value: web3.utils.toWei(0.001))
```

注意这个 `value` 字段， JavaScript 调用来指定发送多少(0.001)`以太`。如果把事务想象成一个信封，你发送到函数的参数就是信的内容。 添加一个 `value` 很像在信封里面放钱 —— 信件内容和钱同时发送给了接收者。

> 注意： 如果一个函数没标记为`payable`， 而你尝试利用上面的方法发送以太，函数将拒绝你的事务。



# 第2章: 提现

在你发送以太之后，它将被存储进以合约的以太坊账户中， 并冻结在哪里 —— 除非你添加一个函数来从合约中把以太提现。

你可以写一个函数来从合约中提现以太，类似这样：

```solidity
contract GetPaid is Ownable {
  function withdraw() external onlyOwner {
    owner.transfer(this.balance);
  }
}
```

注意我们使用 `Ownable` 合约中的 `owner` 和 `onlyOwner`，假定它已经被引入了。

你可以通过 `transfer` 函数向一个地址发送以太， 然后 `this.balance` 将返回当前合约存储了多少以太。 所以如果100个用户每人向我们支付1以太， `this.balance` 将是100以太。

你可以通过 `transfer` 向任何以太坊地址付钱。 比如，你可以有一个函数在 `msg.sender` 超额付款的时候给他们退钱：

```
uint itemFee = 0.001 ether;
msg.sender.transfer(msg.value - itemFee);
```

或者在一个有卖家和卖家的合约中， 你可以把卖家的地址存储起来， 当有人买了它的东西的时候，把买家支付的钱发送给它 `seller.transfer(msg.value)`。

有很多例子来展示什么让以太坊编程如此之酷 —— 你可以拥有一个不被任何人控制的去中心化市场。



# 第4章: 随机数

## 用 `keccak256` 来制造随机数。

Solidity 中最好的随机数生成器是 `keccak256` 哈希函数.

我们可以这样来生成一些随机数

```solidity
// 生成一个0到100的随机数:
uint randNonce = 0;
uint random = uint(keccak256(now, msg.sender, randNonce)) % 100;
randNonce++;
uint random2 = uint(keccak256(now, msg.sender, randNonce)) % 100;
```

这个方法首先拿到 `now` 的时间戳、 `msg.sender`、 以及一个自增数 `nonce` （一个仅会被使用一次的数，这样我们就不会对相同的输入值调用一次以上哈希函数了）。

然后利用 `keccak` 把输入的值转变为一个哈希值, 再将哈希值转换为 `uint`, 然后利用 `% 100` 来取最后两位, 就生成了一个0到100之间随机数了。

### 这个方法很容易被不诚实的节点攻击

在以太坊上, 当你在和一个合约上调用函数的时候, 你会把它广播给一个节点或者在网络上的 ***transaction\*** 节点们。 网络上的节点将收集很多事务, 试着成为第一个解决计算密集型数学问题的人，作为“工作证明”，然后将“工作证明”(Proof of Work, PoW)和事务一起作为一个 ***block\*** 发布在网络上。

一旦一个节点解决了一个PoW, 其他节点就会停止尝试解决这个 PoW, 并验证其他节点的事务列表是有效的，然后接受这个节点转而尝试解决下一个节点。

**这就让我们的随机数函数变得可利用了**

我们假设我们有一个硬币翻转合约——正面你赢双倍钱，反面你输掉所有的钱。假如它使用上面的方法来决定是正面还是反面 (`random >= 50` 算正面, `random < 50` 算反面)。

如果我正运行一个节点，我可以 **只对我自己的节点** 发布一个事务，且不分享它。 我可以运行硬币翻转方法来偷窥我的输赢 — 如果我输了，我就不把这个事务包含进我要解决的下一个区块中去。我可以一直运行这个方法，直到我赢得了硬币翻转并解决了下一个区块，然后获利。

## 所以我们该如何在以太坊上安全地生成随机数呢

因为区块链的全部内容对所有参与者来说是透明的， 这就让这个问题变得很难，它的解决方法不在本课程讨论范围，你可以阅读 [这个 StackOverflow 上的讨论](https://ethereum.stackexchange.com/questions/191/how-can-i-securely-generate-a-random-number-in-my-smart-contract) 来获得一些主意。 一个方法是利用 ***oracle\*** 来访问以太坊区块链之外的随机数函数。

当然， 因为网络上成千上万的以太坊节点都在竞争解决下一个区块，我能成功解决下一个区块的几率非常之低。 这将花费我们巨大的计算资源来开发这个获利方法 — 但是如果奖励异常地高(比如我可以在硬币翻转函数中赢得 1个亿)， 那就很值得去攻击了。

所以尽管这个方法在以太坊上不安全，在实际中，除非我们的随机函数有一大笔钱在上面，你游戏的用户一般是没有足够的资源去攻击的。

因为在这个教程中，我们只是在编写一个简单的游戏来做演示，也没有真正的钱在里面，所以我们决定接受这个不足之处，使用这个简单的随机数生成函数。但是要谨记它是不安全的。



# ERC721 标准

https://ethereum.org/zh/developers/docs/standards/tokens/erc-721/

**什么是非同质化代币？**

非同质化代币（NFT）用于以唯一的方式标识某人或者某物。 此类型的代币可以被完美地用于出售下列物品的平台：收藏品、密钥、彩票、音乐会座位编号、体育比赛等。 这种类型的代币有着惊人的潜力，因此它需要一个适当的标准。ERC-721 就是为解决这个问题而来！

**ERC-721 是什么？**

ERC-721 为 NFT 引入了一个标准，换言之，这种类型的代币是独一无二的，并且可能与来自同一智能合约的另一代币有不同的价值，也许是因为它的年份、稀有性、甚至是它的观感。 稍等，看起来怎么样呢？

是的。 所有 NFTs 都有一个 `uint256` 变量，名为 `tokenId`，所以对于任何 ERC-721 合约，这对值`contract address, tokenId` 必须是全局唯一的。 也就是说，去中心化应用程序可以有一个“转换器”， 使用 `tokenId` 作为输入并输出一些很酷的事物图像，例如僵尸、武器、技能或神奇的小猫咪！

ERC-721（Ethereum Request for Comments 721），由 William Entriken、Dieter Shirley、Jacob Evans、Nastassia Sachs 在 2018 年 1 月提出，是一个在智能合约中实现代币 API 的非同质化代币标准。

它提供了一些功能，例如将代币从一个帐户转移到另一个帐户，获取帐户的当前代币余额，获取代币的所有者，以及整个网络的可用代币总供应量。 除此之外，它还具有其他功能，例如批准帐户中一定数量的代币可以被第三方帐户转移。

如果一个智能合约实现了下列方法和事件，它就可以被称为 ERC-721 非同质化代币合约。 一旦被部署，它将负责跟踪在以太坊上创建的代币。





# 第4章: 重构

嘿嘿！我们刚刚的代码中其实有个错误，以至于其根本无法通过编译，你发现了没？

在前一个章节我们定义了一个叫 `ownerOf` 的函数。但如果你还记得第4课的内容，我们同样在`zombiefeeding.sol` 里以 `ownerOf` 命名创建了一个 `modifier`（修饰符）。

如果你尝试编译这段代码，编译器会给你一个错误说你`不能有相同名称的修饰符和函数`。

所以我们应该把在 `ZombieOwnership` 里的函数名称改成别的吗？

不，我们不能那样做！！！要记得，我们正在用 ERC721 代币标准，意味着`其他合约将期望我们的合约以这些确切的名称来定义函数`。这就是这些标准实用的原因——如果另一个合约知道我们的合约符合 ERC721 标准，它可以直接与我们交互，而无需了解任何关于我们内部如何实现的细节。

所以，那意味着我们将必须重构我们第4课中的代码，将 `modifier` 的名称换成别的。

# 第5章: ERC721: 转移标准

好了，我们将冲突修复了！

现在我们将通过学习把所有权从一个人转移给另一个人来继续我们的 ERC721 规范的实现。

注意 ERC721 规范有两种不同的方法来转移代币：

```solidity
// 第一种
function transfer(address _to, uint256 _tokenId) public;

// 第二种
function approve(address _to, uint256 _tokenId) public;
function takeOwnership(uint256 _tokenId) public;
```

1. 第一种方法是代币的拥有者调用`transfer` 方法，传入他想转移到的 `address` 和他想转移的代币的 `_tokenId`。
2. 第二种方法是代币拥有者首先调用 `approve`，然后传入与以上相同的参数。接着，该合约会存储谁被允许提取代币，通常存储到一个 `mapping (uint256 => address)` 里。然后，当有人调用 `takeOwnership` 时，合约会检查 `msg.sender` 是否得到拥有者的批准来提取代币，如果是，则将代币转移给他。

你注意到了吗，`transfer` 和 `takeOwnership` 都将包含相同的转移逻辑，只是以相反的顺序。 （一种情况是代币的发送者调用函数；另一种情况是代币的接收者调用它）。

所以我们把这个逻辑抽象成它自己的私有函数 `_transfer`，然后由这两个函数来调用它。 这样我们就不用写重复的代码了。





### 合约安全增强: 溢出和下溢

我们将来学习你在编写智能合约的时候需要注意的一个主要的安全特性：防止溢出和下溢。

什么是 **_溢出_** (***overflow\***)?

假设我们有一个 `uint8`, 只能存储8 bit数据。这意味着我们能存储的最大数字就是二进制 `11111111` (或者说十进制的 2^8 - 1 = 255).

来看看下面的代码。最后 `number` 将会是什么值？

```
uint8 number = 255;
number++;
```

在这个例子中，我们导致了溢出 — 虽然我们加了1， 但是 `number` 出乎意料地等于 `0`了。 (如果你给二进制 `11111111` 加1, 它将被重置为 `00000000`，就像钟表从 `23:59` 走向 `00:00`)。

下溢(`underflow`)也类似，如果你从一个等于 `0` 的 `uint8` 减去 `1`, 它将变成 `255` (因为 `uint` 是无符号的，其不能等于负数)。

虽然我们在这里不使用 `uint8`，而且每次给一个 `uint256` 加 `1` 也不太可能溢出 (2^256 真的是一个很大的数了)，在我们的合约中添加一些保护机制依然是非常有必要的，以防我们的 DApp 以后出现什么异常情况。



### 使用 SafeMath

为了防止这些情况，OpenZeppelin 建立了一个叫做 SafeMath 的 **_库_**(***library\***)，默认情况下可以防止这些问题。

不过在我们使用之前…… 什么叫做库?

一个**_库_** 是 Solidity 中一种特殊的合约。其中一个有用的功能是给原始数据类型增加一些方法。

比如，使用 SafeMath 库的时候，我们将使用 `using SafeMath for uint256` 这样的语法。 SafeMath 库有四个方法 — `add`， `sub`， `mul`， 以及 `div`。现在我们可以这样来让 `uint256` 调用这些方法：

```
using SafeMath for uint256;

uint256 a = 5;
uint256 b = a.add(3); // 5 + 3 = 8
uint256 c = a.mul(2); // 5 * 2 = 10
```

我们将在下一章来学习这些方法，不过现在我们先将 SafeMath 库添加进我们的合约。





# 第10章: SafeMath 第二部分

来看看 SafeMath 的部分代码:

```solidity
library SafeMath {
	// 乘法
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

	// 除法
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

	// 减法
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

	// 加法
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}
```

首先我们有了 `library` 关键字 — 库和 `合约`很相似，但是又有一些不同。 就我们的目的而言，库允许我们使用 `using` 关键字，它可以自动把库的所有方法添加给一个数据类型：

```solidity
using SafeMath for uint;
// 这下我们可以为任何 uint 调用这些方法了
uint test = 2;
test = test.mul(3); // test 等于 6 了
test = test.add(5); // test 等于 11 了
```

注意 `mul` 和 `add` 其实都需要两个参数。 在我们声明了 `using SafeMath for uint` 后，我们用来调用这些方法的 `uint` 就自动被作为第一个参数传递进去了(在此例中就是 `test`)

我们来看看 `add` 的源代码看 SafeMath 做了什么:

```solidity
function add(uint256 a, uint256 b) internal pure returns (uint256) {
  uint256 c = a + b;
  assert(c >= a);
  return c;
}
```

基本上 `add` 只是像 `+` 一样对两个 `uint` 相加， 但是它用一个 `assert` 语句来确保结果大于 `a`。这样就防止了溢出。

`assert` 和 `require` 相似，若结果为否它就会抛出错误。

 `assert` 和 `require` 区别在于，`require` 若失败则会返还给用户剩下的 gas， `assert` 则不会。所以大部分情况下，你写代码的时候会比较喜欢 `require`，`assert` 只在代码可能出现严重错误的时候使用，比如 `uint` 溢出。

所以简而言之， SafeMath 的 `add`， `sub`， `mul`， 和 `div` 方法只做简单的四则运算，然后在发生溢出或下溢的时候抛出错误。

### 在我们的代码里使用 SafeMath。

为了防止溢出和下溢，我们可以在我们的代码里找 `+`， `-`， `*`， 或 `/`，然后替换为 `add`, `sub`, `mul`, `div`.

比如，与其这样做:

```solidity
myUint++;
```

我们这样做：

```solidity
myUint = myUint.add(1);
```