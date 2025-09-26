// SPDX-License-Identifier: MIT
pragma solidity ~0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 作业 1：ERC20 代币
任务：参考 openzeppelin-contracts/contracts/token/ERC20/IERC20.sol实现一个简单的 ERC20 代币合约。要求： 
1.合约包含以下标准 ERC20 功能：
2.balanceOf：查询账户余额。
3.transfer：转账。
4.approve 和 transferFrom：授权和代扣转账。
5.使用 event 记录转账和授权操作。
6.提供 mint 函数，允许合约所有者增发代币。
提示：
 使用 mapping 存储账户余额和授权信息。
使用 event 定义 Transfer 和 Approval 事件。
部署到sepolia 测试网，导入到自己的钱包
 */
contract MyERC20 is IERC20 {
    // 代币名称
    string public name = "MIMILuke";
    // 代币符号
    string public symbol = "ML";
    // 小数位数
    uint256 public decimals = 18;
    // 总供应量
    uint256 public totalSupply;

    event Transfer(address indexed from, address to, uint256 value, uint256 indexed timestamp);
    
    event Approval(address indexed from, address to, uint256 value, uint256 indexed timestamp);
    
    // 账户余额映射
    mapping(address account => uint256 value) private _balances;
    // 授权映射: 所有者 => 被授权者 => 授权金额
    mapping(address from=> mapping(address to => uint256 value)) private _allowances;
    
    // 合约所有者
    address private _owner;

    /**
     * @dev 构造函数，初始化代币信息并设置所有者
     */
    constructor(string memory _name, string memory _symbol, uint256 initialSupply) {
        name = _name;
        symbol = _symbol;
        _owner = msg.sender;
        // 初始发行并分配给部署者
        _mint(msg.sender, initialSupply * 10 **decimals);
    }

    function allowance(address owner, address spender) external view returns (uint256) {
          return _allowances[owner][spender];
    }

    /**
     * @dev 检查调用者是否为所有者
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, " caller is not the owner");
        _;
    }

    /**
     * @dev 实现IERC20接口的balanceOf函数
     * @return 账户的代币余额
     */
    function balanceOf(address account) public view override returns (uint256) {
          return _balances[account];
    }

    /**
     * @dev 实现IERC20接口的transfer函数
     * @return 操作是否成功
     */
     function transfer(address to, uint256 amount) public override returns (bool){
          address from = msg.sender;
          _transfer(from, to, amount);
          return true;
     }

    /**
     * @dev 实现IERC20接口的approve函数
     * @return 操作是否成功
     */
     function approve(address spender, uint256 amount) public override returns (bool) {
          address from = msg.sender;
          _approve(from, spender, amount);
          return true;
     }

    /**
     * @dev 实现IERC20接口的transferFrom函数
     * @return 操作是否成功
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev 内部转账逻辑
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        require(from != address(0), " transfer from the zero address");
        require(to != address(0), " transfer to the zero address");
        require(_balances[from] >= amount, " insufficient balance");

        unchecked {
            _balances[from] -= amount;
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount, block.timestamp);
    }

    /**
     * @dev 内部授权逻辑
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), " approve from the zero address");
        require(spender != address(0), " approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount, block.timestamp);
    }

    /**
     * @dev 消耗授权额度
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        uint256 currentAllowance = _allowances[owner][spender];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, " allowance exceeded");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev 增发代币，仅所有者可调用
     */
    function mint(address to, uint256 amount) public onlyOwner {
        require(to != address(0), " mint to the zero address");
        _mint(to, amount * 10** uint256(decimals));
    }

    /**
     * @dev 内部增发逻辑
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), " mint to the zero address");

        totalSupply += amount;
        unchecked {
          _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount, block.timestamp);
    }
}