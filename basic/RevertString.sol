// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/**
2.反转字符串 (Reverse String)
题目描述：反转一个字符串。输入 "abcde"，输出 "edcba"
**/

contract RevertString {
    
    function reverseStr(string calldata str) public pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        uint256 length = strBytes.length;
        for (uint256 i = 0; i < length / 2; i++) {
            (strBytes[i], strBytes[length - i - 1]) = (strBytes[length - i - 1], strBytes[i]);
        }
        return string(strBytes);
    }

}