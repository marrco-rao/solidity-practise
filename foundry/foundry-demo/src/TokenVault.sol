// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract TokenVault {
    using SafeERC20 for IERC20;

    // 存储每个用户对每种代币的余额
    mapping(address user => mapping(address token => uint256)) public balances;

    //  事件：存款
    event Deposited(address indexed user, address indexed token, uint256 amount);
    //  事件：取款
    event Withdrawn(address indexed user, address indexed token, uint256 amount);

    /*
     * @dev  存入代币
     * @param token 代币合约地址
     * @param amount 存入数量
     */
    function deposit(address token, uint256 amount) external  {
        require(token != address(0), "TokenVault: Invalid token address");
        require(amount > 0, "TokenVault: Amount must be greater than zero");

        // 从用户账户转移代币到合约
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        // 更新用户余额
        balances[msg.sender][token] += amount;
        // 触发存款事件
        emit Deposited(msg.sender, token, amount);
    }

    /**
     * @dev 提取代币
     * @param token 代币合约地址
     * @param amount 提取数量
     */
    function withdraw(address token, uint256 amount) external {
        require(token != address(0), "TokenVault: Invalid token address");
        require(amount > 0, "TokenVault: Amount must be greater than zero");

        // 检查用户余额是否足够
        require(balances[msg.sender][token] >= amount, "TokenVault: Insufficient balance");
        // 更新用户余额：先更新状态，后转账，防止重入攻击
        balances[msg.sender][token] -= amount;
        // 将代币转移回用户
        IERC20(token).safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, token, amount);
    }

    /**
     * @dev 查询指定用户对指定代币的余额
     * @param user 用户地址
     * @param token 代币合约地址
     * @return uint256 用户余额
     */
    function getBalance(address user, address token) external view returns (uint256) {
        return balances[user][token];           
    }
}