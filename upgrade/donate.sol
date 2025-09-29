// SPDX-License-Identifier: MIT
pragma solidity ~0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
作业3：编写一个讨饭合约
任务目标
使用 Solidity 编写一个合约，允许用户向合约地址发送以太币。
记录每个捐赠者的地址和捐赠金额。
允许合约所有者提取所有捐赠的资金。

任务步骤
编写合约
创建一个名为 BeggingContract 的合约。
合约应包含以下功能：
一个 mapping 来记录每个捐赠者的捐赠金额。
一个 donate 函数，允许用户向合约发送以太币，并记录捐赠信息。
一个 withdraw 函数，允许合约所有者提取所有资金。
一个 getDonation 函数，允许查询某个地址的捐赠金额。
使用 payable 修饰符和 address.transfer 实现支付和提款。
部署合约
在 Remix IDE 中编译合约。
部署合约到 Goerli 或 Sepolia 测试网。
测试合约
使用 MetaMask 向合约发送以太币，测试 donate 功能。
调用 withdraw 函数，测试合约所有者是否可以提取资金。
调用 getDonation 函数，查询某个地址的捐赠金额。
*/
contract BeggingContract {
    using Strings for uint256;
    event Donate(address indexed _from, uint256 _amount);
    event Withdraw(address indexed _to, uint256 _amount);
    mapping(address donater=>uint256 amount) public donations; // 记录每个捐赠者的捐赠金额
    address public owner; // 合约所有者
    uint256 public totalDonations; // 总捐赠金额


    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        _checkOwner();
        _;
    }

    function donate() public payable {
        donations[msg.sender] += msg.value;
        totalDonations += msg.value;
        emit Donate(msg.sender,msg.value);
    }

    function _checkOwner() private view {
        require(msg.sender == owner, "You are not the owner");
    }

     function withdraw() public onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
        emit Withdraw(msg.sender,address(this).balance);
    }

    function getDonation(address addr) public view returns (uint256) {
        require(donations[addr] != 0, "You have not donated yet");
        return donations[addr];
    }

    function getTotalDonations() public view returns (uint256) {
        return totalDonations;
    }

}