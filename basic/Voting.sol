// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
/**
 1.创建一个名为Voting的合约，包含以下功能：
一个mapping来存储候选人的得票数
一个vote函数，允许用户投票给某个候选人
一个getVotes函数，返回某个候选人的得票数
一个resetVotes函数，重置所有候选人的得票数
**/
contract Voting is Ownable{
    event VoteReset(string indexed name, uint256 oldCount);
    mapping(string name => uint256 counts) private _voteCounts;
    string[] names;
    
    constructor() Ownable(msg.sender) {}

    function vote(string memory name) external  {
        if (_voteCounts[name]==0) {
            names.push(name);
        }
        _voteCounts[name] += 1;
        
    }

    function getVotes(string memory name) external view returns (uint256) {
        return _voteCounts[name];
    }
    
    receive() external payable { }

    function resetVotes() public onlyOwner{
        for (uint i=0;i<names.length;i++) {
            resetVotes(names[i]);
        }
    }
    
     function resetVotes(string memory name) public onlyOwner{
        require(bytes(name).length>0, "Name must input");
        uint256 oldCount = _voteCounts[name];
        delete _voteCounts[name];
        emit VoteReset(name, oldCount);
    }
}