// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;
import {Test} from "forge-std/Test.sol";
import {TokenVault} from "../src/TokenVault.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 1000000 * 10 ** 18);
    }
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract TokenVaultTest is Test {
    TokenVault public vault;
    MockERC20 public token;
    address public user1;
    address public user2;

    // 声明事件Deposited和Withdrawn以便在测试中捕获
    event Deposited(
        address indexed user,
        address indexed token,
        uint256 amount
    );
    event Withdrawn(
        address indexed user,
        address indexed token,
        uint256 amount
    );

    // 每个测试用例运行前都会调用 setUp 函数
    function setUp() public {
        vault = new TokenVault();
        token = new MockERC20("MockToken", "MTK");
        user1 = address(0x1234);
        user2 = address(0x5678);

        // 给用户铸造一些代币
        token.mint(user1, 1000 * 10 ** 18);
        token.mint(user2, 1000 * 10 ** 18);
    }

    function test_Deposit() public {
        uint256 depositAmount = 100 * 10 ** 18;

        // 模拟用户user1批准代币转移
        vm.startPrank(user1);
        token.approve(address(vault), depositAmount);

        // 模拟用户存款
        vault.deposit(address(token), depositAmount);
        vm.stopPrank();

        // 验证余额
        uint256 balance = vault.getBalance(user1, address(token));
        assertEq(balance, depositAmount);
    }

    function test_Withdraw() public {
        uint256 depositAmount = 200 * 10 ** 18;
        uint256 withdrawAmount = 150 * 10 ** 18;

        // 模拟用户批准并存款
        vm.startPrank(user1);
        token.approve(address(vault), depositAmount);
        vault.deposit(address(token), depositAmount);
        vm.stopPrank();
        // 模拟用户取款
        vm.prank(user1);
        vault.withdraw(address(token), withdrawAmount);

        // 验证余额
        uint256 balance = vault.getBalance(user1, address(token));
        assertEq(balance, depositAmount - withdrawAmount);
    }

    function test_Withdraw_InsufficientBalance() public {
        uint256 depositAmount = 50 * 10 ** 18;
        uint256 withdrawAmount = 100 * 10 ** 18;

        // 模拟用户批准并存款
        vm.startPrank(user1);
        token.approve(address(vault), depositAmount);
        vault.deposit(address(token), depositAmount);
        // 尝试取款超过余额，应该失败
        vm.expectRevert("TokenVault: Insufficient balance");
        vault.withdraw(address(token), withdrawAmount);
        vm.stopPrank();
    }

    // 测试多个用户存取款
    function test_MultipleUsers() public {
        uint256 user1Deposit = 300 * 10 ** 18;
        uint256 user2Deposit = 400 * 10 ** 18;

        // 模拟用户1批准并存款
        vm.startPrank(user1);
        token.approve(address(vault), user1Deposit);
        vault.deposit(address(token), user1Deposit);
        vm.stopPrank();

        // 模拟用户2批准并存款
        vm.startPrank(user2);
        token.approve(address(vault), user2Deposit);
        vault.deposit(address(token), user2Deposit);
        vm.stopPrank();

        // 验证余额
        uint256 user1Balance = vault.getBalance(user1, address(token));
        uint256 user2Balance = vault.getBalance(user2, address(token));
        assertEq(user1Balance, user1Deposit);
        assertEq(user2Balance, user2Deposit);

        // 验证合约总余额
        uint256 contractBalance = token.balanceOf(address(vault));
        assertEq(contractBalance, user1Deposit + user2Deposit);
    }

    // 测试事件
    function test_Events() public {
        uint256 depositAmount = 150 * 10 ** 18;

        vm.startPrank(user1);
        token.approve(address(vault), depositAmount);
        // 期待Deposited事件
        vm.expectEmit(true, true, false, false);
        emit Deposited(user1, address(token), depositAmount);
        vault.deposit(address(token), depositAmount);
        vm.stopPrank();
    }
}