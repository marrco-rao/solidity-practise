// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {TokenVault} from "../src/TokenVault.sol";

contract DeployTokenVault is Script {

    function setUp() public {}

    function run() external {
        // 从环境变量读取私钥
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        // 输出部署信息
        console2.log("Deploying TokenVault contract with account:", deployer);
        console2.log(
            "Account balance:",
            deployer.balance
        );

        // 开始广播交易
        vm.startBroadcast(deployerPrivateKey);

        TokenVault newTokenVault = new TokenVault();
    
        vm.stopBroadcast();
        console2.log("TokenVault deployed at:", address(newTokenVault));

    }
}
