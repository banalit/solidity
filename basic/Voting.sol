// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/**
 1.创建一个名为Voting的合约，包含以下功能：
一个mapping来存储候选人的得票数
一个vote函数，允许用户投票给某个候选人
一个getVotes函数，返回某个候选人的得票数
一个resetVotes函数，重置所有候选人的得票数
**/

contract Voting {
    mapping(string name => uint256 counts) private _voteCounts;

    function vote(string memory name) external  {
        _voteCounts[name] += 1;    
    }

    function getVotes(string memory name) external view returns (uint256) {
        return _voteCounts[name];
    }

     function resetVotes() public {
        _voteCounts = new mapping(string name => uint256 counts);
    }
    
     function resetVotes(string memory name) public {
        delete _voteCounts[name];
    }
}